//
//  TestPostingController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 2/20/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class TestPostingController : BuspassEventListener {
    
    var api : BuspassApi
    
    init(api : BuspassApi) {
        self.api = api
        registerForEvents()
    }
    
    func registerForEvents() {
        api.bgEvents.registerForEvent("JourneyStartPosting", listener: self)
        api.bgEvents.registerForEvent("JourneyStopPosting", listener: self)
        api.uiEvents.registerForEvent("UpdateProgress", listener: self)
    }
    
    func unregisterForEvents() {
        api.bgEvents.unregisterForEvent("JourneyStartPosting", listener: self)
        api.bgEvents.unregisterForEvent("JourneyStopPosting", listener: self)
        api.uiEvents.unregisterForEvent("UpdateProgress", listener: self)
    }
    
    var postingRoute : Route?
    func onBuspassEvent(event: BuspassEvent) {
        if event.eventName == "JourneyStartPosting" {
            let eventData = event.eventData as? JourneyEventData
            if eventData != nil {
                let route = eventData!.route
                postingRoute = route
            }
        } else if event.eventName == "JourneyStopPosting" {
            postingRoute = nil
            
        } else if event.eventName == "UpdateProgress" {
            let eventData = event.eventData as? UpdateProgressEventData
            if eventData != nil {
                if eventData!.action == InvocationProgressEvent.U_FINISH {
                    if postingRoute != nil {
                        let loc = postingRoute!.lastKnownLocation
                        if loc != nil {
                            let location = Location(name: "\(UtilsTime.current())", lon: loc!.getLongitude(), lat: loc!.getLatitude())
                            location.bearing = GeoCalc.to_degrees(postingRoute!.lastKnownDirection!)
                            /// TODO: Make this mean something
                            location.speed = 200.0
                            location.source = "TestPostingController"
                            let evd = LocationEventData(location: location)
                            api.uiEvents.postEvent("LocationChanged", data: evd)
                            return
                        }
                        if loc != nil && postingRoute!.getPaths().count > 0 {
                            let offPath = GeoPathUtils.offPath(postingRoute!.getPaths()[0], point: loc!)
                            let dpoints = GeoPathUtils.whereOnPath(postingRoute!.getPaths()[0], buffer: postingRoute!.distanceTolerance, point: loc!)
                            if dpoints.count > 0 {
                                let dpoint = dpoints[0]
                                // The 200 is arbitrary here.
                                let jpoint = GeoPathUtils.whereOnPathByDistance(postingRoute!.getPaths()[0], distance: dpoint.distance + 200)
                                if jpoint != nil {
                                    let location = Location(name: "\(UtilsTime.current())", lon: jpoint!.geoPoint.getLongitude(), lat: jpoint!.geoPoint.getLatitude())
                                    location.bearing = jpoint!.bearing
                                    /// TODO: Make this mean something
                                    location.speed = 200.0
                                    location.source = "TestPostingController"
                                    let evd = LocationEventData(location: location)
                                    api.uiEvents.postEvent("LocationChanged", data: evd)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}