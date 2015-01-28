//
//  JourneyBasket.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public protocol ProgressListener {
    func onSyncStart()
    func onSyncEnd(nRoutes : Int)
    func onRouteStart(iRoute : Int)
    func onRouteEnd(iRoute : Int)
    func onDone()
}

public protocol OnIOErrorListener {
    func onIOError(journeyBasket : JourneyBasket, statusLine : HttpStatusLine)
}
public protocol OnJourneyAddedListener {
    func onJourneyAdded(journeyBasket : JourneyBasket, journey : Route)
}
public protocol OnJourneyRemovedListener {
    func onJourneyRemoved(journeyBasket : JourneyBasket, journey : Route)
}
public protocol OnBasketUpdateListener {
    func onBasketUpdate(journeyBasket : JourneyBasket)
}

public class JourneyBasket {
    public var api : BuspassApi
    public var journeyStore : JourneyStore
    public var journeys : [Route] = [Route]()
    public var patterns : [JourneyPattern] = [JourneyPattern]()
    public var journeyMap : [String:Route] = [String:Route]()
    
    public init(api : BuspassApi, journeyStore : JourneyStore) {
        self.api = api
        self.journeyStore = journeyStore
    }
    
    public func getRoute(id : String) -> Route? {
        return journeyMap[id]
    }
    
    public func getAllRoutes() -> [Route] {
        return [Route](journeys);
    }
    
    public func getAllJourneys() -> [Route] {
        return journeys.filter({(x) in x.isJourney()})
    }
    
    public func getAllActiveJourneys() -> [Route] {
        return journeys.filter({(x) in x.isActiveJourney()})
    }
    
    public func setJourneys(journeys : [Route]) {
        self.journeys = journeys
        self.updateJourneyMap()
    }
    
    public func empty() {
        let copyJourneys = [Route](journeys)
        setJourneys([Route]())
        for route in copyJourneys {
            notifyOnJourneyRemovedListeners(route)
        }
        notifyOnBasketUpdateListeners()
    }
    
    public func updateJourneyMap() {
        journeyMap.removeAll(keepCapacity: true)
        for journey in journeys {
            journeyMap[journey.id!] = journey
        }
        
    }
    
    public func sync(journeyids : [NameId], progress : ProgressListener?, ioError : OnIOErrorListener? ) {
        let copy_journeys = [Route](journeys)
        var addedJourneys = [Route]()
        var removedJourneys = [Route]()
        var keepJourneys = [Route]()
        var newJourneys = [Route]()
        var index = 0
        for nameid in journeyids {
            progress?.onRouteStart(index)
            var addJourney = true
            for route in copy_journeys {
                if (route.id == nameid.id) {
                    if (route.version < nameid.version) {
                        addJourney = true
                        journeyStore.removeJourney(nameid.id)
                    } else {
                        addJourney = false
                    }
                    route.updateStartTimes(nameid)
                    break
                }
            }
            if addJourney {
                let route = retrieveRouteJourney(nameid)
                if (route != nil) {
                    if route!.isJourney() {
                        let measure = route!.getStartingMeasure()
                    }
                    addedJourneys.append(route!)
                }
            }
            progress?.onRouteEnd(index)
            index += 1
        }
        for route in copy_journeys {
            var removeJourney = false
            for nameid in journeyids {
                if (route.id == nameid.id) {
                    if (route.version != nameid.version) {
                        removeJourney = true
                    }
                    break
                }
            }
            if removeJourney {
               removedJourneys.append(route)
            } else {
                if route.isJourney() {
                    let measure = route.getStartingMeasure()
                }
                keepJourneys.append(route)
            }
        }
        newJourneys += keepJourneys
        newJourneys += addedJourneys
        setJourneys(newJourneys)
        for route in removedJourneys {
            route.setActive(false)
            notifyOnJourneyRemovedListeners(route)
        }
        for route in addedJourneys {
            route.setActive(true)
            notifyOnJourneyAddedListeners(route)
        }
        notifyOnBasketUpdateListeners()
    }
    
    public func retrieveRouteJourney(nameid : NameId) -> Route? {
        var route = journeyStore.getJourney(nameid.id)
        if (route == nil) {
            route = retrieveRouteAndStore(nameid)
        }
        if (route != nil) {
            if (route!.isJourney() && route!.patternid != nil) {
                var pattern = journeyStore.getPattern(route!.patternid!)
                if (pattern == nil) {
                    pattern = retrieveAndStoreJourneyPattern(route!.patternid!)
                }
            } else if (route!.isRouteDefinition() && route!.patternids != nil) {
                for pid in route!.patternids! {
                    var pattern = journeyStore.getPattern(pid)
                    if (pattern == nil) {
                        pattern = retrieveAndStoreJourneyPattern(pid)
                    }
                }
            }
        }
        return route
    }
    
    public func retrieveAndStoreJourneyPattern( id : String ) -> JourneyPattern? {
        let pattern = retrieveJourneyPattern(id)
        if (pattern != nil) {
            journeyStore.storePattern(pattern!)
        }
        return pattern
    }
    
    public func retrieveRouteAndStore(nameid : NameId) -> Route? {
        let route = retrieveRoute(nameid)
        if (route != nil) {
            journeyStore.storeJourney(route!)
        }
        return route
    }
    
    public func retrieveRoute(nameid :NameId) -> Route? {
        return api.getRouteDefinition(nameid)
    }
    
    public func retrieveJourneyPattern(id  : String) -> JourneyPattern? {
        return api.getJourneyPattern(id)
    }
    
    private var onJourneyAddedListeners : [OnJourneyAddedListener] = [OnJourneyAddedListener]()
    public func addOnJourneyAddedListeners(listener : OnJourneyAddedListener) {
        onJourneyAddedListeners.append(listener)
    }
    public func notifyOnJourneyAddedListeners(route : Route) {
        for listener in onJourneyAddedListeners {
            listener.onJourneyAdded(self, journey: route)
        }
    }
    
    private var onJourneyRemmovedListeners : [OnJourneyRemovedListener] = [OnJourneyRemovedListener]()
    public func addOnJourneyRemovedListeners(listener : OnJourneyRemovedListener) {
        onJourneyRemmovedListeners.append(listener)
    }
    public func notifyOnJourneyRemovedListeners(route : Route) {
        for listener in onJourneyRemmovedListeners {
            listener.onJourneyRemoved(self, journey: route)
        }
    }
    private var onBasketUpdateListeners : [OnBasketUpdateListener] = [OnBasketUpdateListener]()
    public func aedBasketUpdateListeners(listener : OnBasketUpdateListener) {
        onBasketUpdateListeners.append(listener)
    }

    public func notifyOnBasketUpdateListeners() {
        for listener in onBasketUpdateListeners {
            listener.onBasketUpdate(self)
        }
    }
}