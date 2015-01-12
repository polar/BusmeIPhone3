//
//  JourneyPostingController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation

public class JourneyLocationEventData {
    public var route : Route
    public var location : PostLocation
    public var role : String
    
    public init( route : Route, location: PostLocation, role : String) {
        self.route = route
        self.location = location
        self.role = role
    }
}

public class JourneyPostingController : BuspassEventListener {
    public var api : BuspassApi
    
    public init(api : BuspassApi) {
        self.api = api
    }
    public func onBuspassEvent(event: BuspassEvent) {
        let eventData = event.eventData as? JourneyLocationEventData
        if eventData != nil {
            postLocation(eventData!)
        }
    }
    
    public func postLocation(eventData : JourneyLocationEventData) {
        let (status, response) = api.postJourneyLocation(eventData.location, role: eventData.role)
        if (response != nil) {
            if (response == "ok") {
                if (BLog.DEBUG) { BLog.logger.debug("Location Successfully Posted") }
            } else if (response == "notavailable") {
                var evd = JourneyEventData(route: eventData.route, role: eventData.role, location: eventData.location)
                evd.action = JourneyEvent.A_ON_ROUTE_DONE
                evd.reason = JourneyEvent.R_NOT_AVAILABLE
                api.bgEvents.postEvent("JourneyStopPosting", data: evd)
            } else if (response == "notloggedin") {
                api.uiEvents.postEvent("ServerLogout")
            }
        }
    }
}