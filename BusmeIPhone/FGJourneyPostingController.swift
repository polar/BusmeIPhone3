//
//  FGJourneyPostingController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 2/20/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class FGJourneyPostingController : BuspassEventListener {
    
    var api : BuspassApi
    
    init(api : BuspassApi) {
        self.api = api
        registerForEvents()
    }
    
    func registerForEvents() {
        api.bgEvents.registerForEvent("JourneyStartPosting", listener: self)
        api.bgEvents.registerForEvent("JourneyStopPosting", listener: self)
    }
    
    func unregisterForEvents() {
        api.bgEvents.unregisterForEvent("JourneyStopPosting", listener: self)
        api.bgEvents.unregisterForEvent("JourneyStartPosting", listener: self)
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
            let eventData = event.eventData as? JourneyEventData
            if eventData != nil {
                let route = eventData!.route
                if eventData!.reason != JourneyEvent.R_FORCED {
                    var message = "Unknown Reason"
                    switch(eventData!.reason) {
                    case JourneyEvent.R_DISABLED:
                        message = "GPS became disabled."
                    case JourneyEvent.R_OFF_ROUTE:
                        message = "You are off the route."
                    case JourneyEvent.R_SERVICE:
                        message = "There was a service problem."
                    case JourneyEvent.R_NORMAL:
                        message = "The Journey has ended."
                    case JourneyEvent.R_NOT_AVAILABLE:
                        message = "The Journey is no longer in service."
                    default:
                        message = "Unknown Reason"
                    }
                    let startT = UtilsTime.hhmmaForTime(route.getStartTime())
                    let endT = UtilsTime.hhmmaForTime(route.getEndTime())
                    message = "Route \(route.code!) \(startT) - \(endT): " + message
                    Toast(title: "Stopped Posting Locations", message: message, duration: 10).show()
                }
            }
        }
    }
}