//
//  JourneyLocationPoster.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/10/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation


public struct JourneyEvent {
    public static let A_ON_ROUTE_POSTING = 1
    public static let A_AT_ROUTE_START   = 2
    public static let A_OFF_ROUTE        = 3
    public static let A_ON_ROUTE         = 4
    public static let A_UPDATE_ROUTE     = 5
    public static let A_AT_ROUTE_END     = 6
    public static let A_ON_ROUTE_DONE    = 7

    public static let R_NORMAL        = 1
    public static let R_FORCED        = 2
    public static let R_DISABLED      = 3
    public static let R_SERVICE       = 4
    public static let R_OFF_ROUTE     = 5
    public static let R_NOT_AVAILABLE = 6
}

public class JourneyEventData {
    public var route : Route
    public var role : String
    public var action : Int = 0
    public var reason : Int = 0
    public var location : PostLocation?
    
    public init(route : Route, role : String, location : PostLocation? = nil) {
        self.route = route
        self.role = role
        self.location = location
    }
    public init(route : Route, role : String, reason : Int) {
        self.route = route
        self.role = role
        self.reason = reason
    }

}

public class JourneyLocationPoster : BuspassEventListener {
    public var api : BuspassApi
    
    public var postingRoute : Route?
    public var postingPathPoints : [GeoPoint] = [GeoPoint]()
    public var startPoint : GeoPoint?
    public var endPoint : GeoPoint?
    public var postingRole : String = "passenger"
    public var offRouteCount : Int = 0
    public var alreadyPosting : Bool = false
    public var alreadyStarted : Bool = false
    public var alreadyFinished : Bool = false
    
    public init(api : BuspassApi) {
        self.api = api
        registerForEvents()
    }
    
    func registerForEvents() {
        api.uiEvents.registerForEvent("LocationChanged", listener: self)
        api.uiEvents.registerForEvent("LocationProviderDisabled", listener: self)
        api.uiEvents.registerForEvent("LocationProviderEnabled", listener: self)
        
        api.bgEvents.registerForEvent("JourneyStartPosting", listener: self)
        api.bgEvents.registerForEvent("JourneyStopPosting", listener: self)
        api.bgEvents.registerForEvent("JourneyRemoved", listener: self)
    }
    
    func unregisterForEvents() {
        api.uiEvents.unregisterForEvent("LocationChanged", listener: self)
        api.uiEvents.unregisterForEvent("LocationProviderDisabled", listener: self)
        api.uiEvents.unregisterForEvent("LocationProviderEnabled", listener: self)
        
        api.bgEvents.unregisterForEvent("JourneyStartPosting", listener: self)
        api.bgEvents.unregisterForEvent("JourneyStopPosting", listener: self)
        api.bgEvents.unregisterForEvent("JourneyRemoved", listener: self)
    }
    
    public func onBuspassEvent(event: BuspassEvent) {
        let eventName = event.eventName
        // Foreground Thread
        if (eventName ==  "LocationProviderEnabled") {
            onProviderEnabled()
        } else if (eventName ==  "LocationProviderDisabled") {
            onProviderDisabled()
        } else if (eventName ==  "LocationChanged") {
            let eventData = event.eventData as? LocationEventData
            if eventData != nil {
                onLocationChanged(eventData!)
            }
        } else
        // background thread
        if (eventName ==  "JourneyStartPosting") {
            let eventData = event.eventData as? JourneyEventData
            if eventData != nil {
                onJourneyStartPosting(eventData!)
            }
        } else if (eventName ==  "JourneyStopPosting") {
            let eventData = event.eventData as? JourneyEventData
            if eventData != nil {
                onJourneyStopPosting(eventData!)
            }
        } else if (eventName ==  "JourneyRemoved") {
            let evd = event.eventData as? JourneyDisplayEventData
            if (evd != nil) {
                onJourneyRemoved(evd!)
            }
        }
    }
    
    public func reset() {
        self.postingRoute = nil
        self.alreadyPosting = false
        self.alreadyFinished = false
        self.alreadyStarted = false
    }
    
    public func startPosting(route : Route, role : String) {
        self.postingRoute = route
        self.postingRole = role
        self.postingPathPoints = route.getPaths().first!
        self.startPoint = self.postingPathPoints.first
        self.endPoint = self.postingPathPoints.last
    }
    
    public func endPosting(reason : Int = JourneyEvent.R_FORCED) {
        if postingRoute != nil {
            postingRoute!.reporting = false
            notifyOnRouteDone(reason)
        }
    }
    
    public func processLocation( location : Location ) {
        if postingRoute != nil {
            if !alreadyPosting {
                notifyOnRoutePosting(location)
                self.alreadyPosting = true
            }
            let point = GeoCalc.toGeoPoint(location)
            if postingRoute!.lastKnownLocation == nil && GeoCalc.getGeoDistance(point, c2: startPoint!) < Double(api.offRouteDistanceThreshold) {
                if location.speed > 5 && !alreadyStarted {
                    notifyAtRouteStart(location)
                    self.alreadyStarted = true
                }
            }
            postLocation(location)
            notifyUpdateRoute(location)
            // TODO: Wrong, Wrong, could be cycle.
            if GeoCalc.getGeoDistance(point, c2: endPoint!) < Double(api.offRouteDistanceThreshold) {
                if location.speed > 0 && !alreadyFinished {
                    notifyAtRouteEnd(location)
                    self.alreadyFinished = true
                }
            }
        }
    }
    
    public func postLocation( location : Location) {
        let postLocation = PostLocation(journey: postingRoute!, location: location)

        api.bgEvents.postEvent("JourneyLocationPost",
            data: JourneyEventData(route: postingRoute!, role: postingRole, location: postLocation))
    }
    
    public func onProviderEnabled() {
    
    }
    
    public func onProviderDisabled() {
        if postingRoute != nil {
            endPosting(reason: JourneyEvent.R_SERVICE)
        }
    }
    
    public func onJourneyStartPosting(eventData : JourneyEventData) {
        if postingRoute != nil {
            endPosting(reason: JourneyEvent.R_FORCED)
        }
        startPosting(eventData.route, role: eventData.role)
    }
    
    public func onJourneyStopPosting(eventData : JourneyEventData) {
        if postingRoute != nil {
            endPosting(reason: eventData.reason)
        }
    }
    
    public func onLocationChanged(eventData : LocationEventData) {
        processLocation(eventData.location)
    }
    
    public func onJourneyRemoved(eventData : JourneyDisplayEventData) {
        if postingRoute != nil {
            if postingRoute!.id == eventData.id {
                endPosting(reason: JourneyEvent.R_NORMAL)
            }
        }
    }
    
    public func  notifyOnRoutePosting(location : Location) {
        if postingRoute != nil {
            let postLocation = PostLocation(journey: postingRoute!, location: location)
            var eventData = JourneyEventData(route : postingRoute!, role : postingRole, location : postLocation)
            eventData.action = JourneyEvent.A_ON_ROUTE_POSTING
            api.uiEvents.postEvent("JourneyEvent", data: eventData)
        }
    }
    
    public func  notifyAtRouteStart(location : Location) {
        if postingRoute != nil {
            let postLocation = PostLocation(journey: postingRoute!, location: location)
            var eventData = JourneyEventData(route : postingRoute!, role : postingRole, location : postLocation)
            eventData.action = JourneyEvent.A_AT_ROUTE_START
            api.uiEvents.postEvent("JourneyEvent", data: eventData)
        }
    }
    
    public func  notifyOnRoute(location : Location) {
        if postingRoute != nil {
            let postLocation = PostLocation(journey: postingRoute!, location: location)
            var eventData = JourneyEventData(route : postingRoute!, role : postingRole, location : postLocation)
            eventData.action = JourneyEvent.A_ON_ROUTE
            api.uiEvents.postEvent("JourneyEvent", data: eventData)
        }
    }
    
    public func  notifyUpdateRoute(location : Location) {
        if postingRoute != nil {
            let postLocation = PostLocation(journey: postingRoute!, location: location)
            var eventData = JourneyEventData(route : postingRoute!, role : postingRole, location : postLocation)
            eventData.action = JourneyEvent.A_UPDATE_ROUTE
            api.uiEvents.postEvent("JourneyEvent", data: eventData)
        }
    }
    
    public func  notifyOffRoute(location : Location) {
        if postingRoute != nil {
            let postLocation = PostLocation(journey: postingRoute!, location: location)
            var eventData = JourneyEventData(route : postingRoute!, role : postingRole, location : postLocation)
            eventData.action = JourneyEvent.A_OFF_ROUTE
            api.uiEvents.postEvent("JourneyEvent", data: eventData)
        }
    }
    
    public func  notifyAtRouteEnd(location : Location) {
        if postingRoute != nil {
            let postLocation = PostLocation(journey: postingRoute!, location: location)
            var eventData = JourneyEventData(route : postingRoute!, role : postingRole, location : postLocation)
            eventData.action = JourneyEvent.A_AT_ROUTE_END
            api.uiEvents.postEvent("JourneyEvent", data: eventData)
        }
    }
    
    public func  notifyOnRouteDone(reason : Int) {
        if postingRoute != nil {
            var eventData = JourneyEventData(route : postingRoute!, role : postingRole, reason : reason)
            eventData.action = JourneyEvent.A_ON_ROUTE_DONE
            api.uiEvents.postEvent("JourneyEvent", data: eventData)
        }
        reset()
    }
}