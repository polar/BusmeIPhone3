//
//  JourneyBasket.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

protocol ProgressListener {
    func onSyncStart()
    func onSyncEnd(nRoutes : Int)
    func onRouteStart(iRoute : Int)
    func onRouteEnd(iRoute : Int)
    func onDone()
}

protocol OnIOErrorListener : class {
    func onIOError(journeyBasket : JourneyBasket, statusLine : HttpStatusLine)
}
protocol OnJourneyAddedListener : class{
    func onJourneyAdded(journeyBasket : JourneyBasket, journey : Route)
}
protocol OnJourneyRemovedListener :  class {
    func onJourneyRemoved(journeyBasket : JourneyBasket, journey : Route)
}
protocol OnBasketUpdateListener :  class {
    func onBasketUpdate(journeyBasket : JourneyBasket)
}

class JourneyBasket {
    unowned var api : BuspassApi
    unowned var journeyStore : JourneyStore
    var journeys : [Route] = [Route]()
    var patterns : [JourneyPattern] = [JourneyPattern]()
    var journeyMap : [String:Route] = [String:Route]()
    
    init(api : BuspassApi, journeyStore : JourneyStore) {
        self.api = api
        self.journeyStore = journeyStore
    }
    
    func getRoute(id : String) -> Route? {
        return journeyMap[id]
    }
    
    func getAllRoutes() -> [Route] {
        return [Route](journeys);
    }
    
    func getAllJourneys() -> [Route] {
        return journeys.filter({(x) in x.isJourney()})
    }
    
    func getAllActiveJourneys() -> [Route] {
        return journeys.filter({(x) in x.isActiveJourney()})
    }
    
    func setJourneys(journeys : [Route]) {
        self.journeys = journeys
        self.updateJourneyMap()
    }
    
    func empty() {
        let copyJourneys = [Route](journeys)
        setJourneys([Route]())
        for route in copyJourneys {
            notifyOnJourneyRemovedListeners(route)
        }
        notifyOnBasketUpdateListeners()
    }
    
    func updateJourneyMap() {
        journeyMap.removeAll(keepCapacity: true)
        for journey in journeys {
            journeyMap[journey.id!] = journey
        }
        
    }
    
    func sync(journeyids : [NameId], progress : ProgressListener?, ioError : OnIOErrorListener? ) {
        let now = UtilsTime.current()
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
                    addedJourneys.append(route!)
                }
            }
            progress?.onRouteEnd(index)
            index += 1
        }
        for route in copy_journeys {
            var removeJourney = true
            for nameid in journeyids {
                if (route.id == nameid.id) {
                    if (route.version != nameid.version) {
                        removeJourney = true
                    } else {
                        removeJourney = false
                    }
                    break
                }
            }
            // Remove any journeys that are still around that shouldn't be.
            if !removeJourney && route.isJourney() {
                if route.getEndTime() < now {
                    // If we have recent locations, then the bus just might be late.
                    if (route.lastKnownLocation != nil && route.lastLocationUpdate != nil) {
                        if route.lastLocationUpdate! < (now - Int64(1 * 60 * 1000)) {
                            removeJourney = true
                        }
                    } else {
                        // We give it a minute in case we just turned the app on and don't
                        // have a location yet.
                        if route.getEndTime() < (now - Int64(1 * 60 * 1000)) {
                            removeJourney = true
                        }
                    }
                }
            }
            if removeJourney {
               removedJourneys.append(route)
            } else {
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
    
    func retrieveRouteJourney(nameid : NameId) -> Route? {
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
                // Update the route with the scheduled and actual time start.
                route!.updateStartTimes(nameid)
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
    
    func retrieveAndStoreJourneyPattern( id : String ) -> JourneyPattern? {
        let pattern = retrieveJourneyPattern(id)
        if (pattern != nil) {
            journeyStore.storePattern(pattern!)
        }
        return pattern
    }
    
    func retrieveRouteAndStore(nameid : NameId) -> Route? {
        let route = retrieveRoute(nameid)
        if (route != nil) {
            journeyStore.storeJourney(route!)
        }
        return route
    }
    
    func retrieveRoute(nameid :NameId) -> Route? {
        return api.getRouteDefinition(nameid)
    }
    
    func retrieveJourneyPattern(id  : String) -> JourneyPattern? {
        return api.getJourneyPattern(id)
    }
    
    class WeakOnJourneyAddedListenerHelper {
        weak var onJourneyAddedListener : OnJourneyAddedListener?
        init(onJourneyAddedListener : OnJourneyAddedListener) {
            self.onJourneyAddedListener = onJourneyAddedListener
        }
    }
    private var onJourneyAddedListeners : [WeakOnJourneyAddedListenerHelper] = [WeakOnJourneyAddedListenerHelper]()
    func addOnJourneyAddedListeners(listener : OnJourneyAddedListener) {
        let eatme = WeakOnJourneyAddedListenerHelper(onJourneyAddedListener: listener)
        self.onJourneyAddedListeners.append(eatme)
    }
    func notifyOnJourneyAddedListeners(route : Route) {
        for listener in onJourneyAddedListeners {
            listener.onJourneyAddedListener?.onJourneyAdded(self, journey: route)
        }
    }
    
    
    class WeakOnJourneyRemovedListenerHelper {
        weak var onJourneyRemovedListener : OnJourneyRemovedListener?
        init(onJourneyRemovedListener : OnJourneyRemovedListener) {
            self.onJourneyRemovedListener = onJourneyRemovedListener
        }

    }

    private var onJourneyRemmovedListeners : [WeakOnJourneyRemovedListenerHelper] = [WeakOnJourneyRemovedListenerHelper]()
    func addOnJourneyRemovedListeners(listener : OnJourneyRemovedListener) {
        onJourneyRemmovedListeners.append(WeakOnJourneyRemovedListenerHelper(onJourneyRemovedListener: listener))
    }
    func notifyOnJourneyRemovedListeners(route : Route) {
        for listener in onJourneyRemmovedListeners {
            listener.onJourneyRemovedListener?.onJourneyRemoved(self, journey: route)
        }
    }
    class WeakOnBasketUpdateListenerHelper {
        weak var onBasketUpdateListener : OnBasketUpdateListener?
        init(onBasketUpdateListener : OnBasketUpdateListener) {
            self.onBasketUpdateListener = onBasketUpdateListener
        }

    }
    private var onBasketUpdateListeners : [WeakOnBasketUpdateListenerHelper] = [WeakOnBasketUpdateListenerHelper]()
    func aedBasketUpdateListeners(listener : OnBasketUpdateListener) {
        onBasketUpdateListeners.append(WeakOnBasketUpdateListenerHelper(onBasketUpdateListener: listener))
    }

    func notifyOnBasketUpdateListeners() {
        for listener in onBasketUpdateListeners {
            listener.onBasketUpdateListener?.onBasketUpdate(self)
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}