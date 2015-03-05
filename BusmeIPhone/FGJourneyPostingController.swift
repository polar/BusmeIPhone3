//
//  FGJourneyPostingController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 2/20/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class FGJourneyPostingController : JourneyEventController {
    
    override init(api : BuspassApi) {
        super.init(api: api)
    }
    
    override func onRoutePosting(eventData : JourneyEventData) {
        let route = eventData.route
        let name = route.name!
        let code = route.code!
        let vid = route.vid == nil ? "" : " VID \(route.vid!)"
        let startT = UtilsTime.hhmmaForTime(route.getStartTime())
        let endT = UtilsTime.hhmmaForTime(route.getEndTime())
        let msg = "Posting your GPS location for Route \(name)\(vid) \(startT) - \(endT)"
        Toast(title: "Posting Locations", message: msg, duration: 2).show()
    }
    
    override func onRouteStart(eventData : JourneyEventData) {
        
    }
    
    override func onOffRoute(eventData : JourneyEventData) {
        
    }
    
    override func onOnRoute(eventData : JourneyEventData) {
        
    }
    
    override func onUpdateRoute(eventData : JourneyEventData) {
        
    }
    
    override func onAtRouteEnd(eventData : JourneyEventData) {
        
    }
    
    override func onOnRouteEnd(eventData : JourneyEventData) {
        
    }
    
    override func onOnRouteDone(eventData : JourneyEventData) {
        let route = eventData.route
        let name = route.name!
        let code = route.code!
        let vid = route.vid == nil ? "" : "\nVID \(route.vid!)"
        let startT = UtilsTime.hhmmaForTime(route.getStartTime())
        let endT = UtilsTime.hhmmaForTime(route.getEndTime())
        let routeName = "Route \(route.code!): \(route.name!)\(vid)\n\(startT) - \(endT)"
        if eventData.reason != JourneyEvent.R_FORCED {
            var message = "Unknown Reason"
            switch(eventData.reason) {
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
            case JourneyEvent.R_NO_GPS_UPDATE:
                message = "There are no good GPS updates for your phone"
            default:
                message = "Unknown Reason"
            }
            message = "\(routeName)\n" + message
            Toast(title: "Stopped Posting Locations", message: message, duration: 10).show()
        } else {
            Toast(title: "Stopped Posting Locations", message: "at your request", duration: 2).show()
        }
    }
}