//
//  JourneyPostingController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation

class JourneyPostingController : BuspassEventListener {
    var api : BuspassApi
    
    init(api : BuspassApi) {
        self.api = api
        registerForEvents()
    }
    
    func registerForEvents() {
        api.bgEvents.registerForEvent("JourneyLocationPost", listener: self)
    }
    
    func unregisterForEvents() {
        api.bgEvents.unregisterForEvent("JourneyLocationPost", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventData = event.eventData as? JourneyEventData
        if eventData != nil {
            postLocation(eventData!)
        }
    }
    
    func postLocation(eventData : JourneyEventData) {
        let postLocation = eventData.location
        if postLocation != nil {
            let (status, response) = api.postJourneyLocation(postLocation!, role: eventData.role)
            if (response != nil) {
                if (response == "ok") {
                    if (BLog.DEBUG) { BLog.logger.debug("Location Successfully Posted") }
                } else if (response == "notavailable") {
                    var evd = JourneyEventData(route: eventData.route, role: eventData.role, location: eventData.location)
                    evd.action = JourneyEvent.A_ON_ROUTE_DONE
                    evd.reason = JourneyEvent.R_NOT_AVAILABLE
                    api.bgEvents.postEvent("JourneyStopPosting", data: evd)
                } else if (response == "notloggedin") {
                    var evd = JourneyEventData(route: eventData.route, role: eventData.role, location: eventData.location)
                    evd.action = JourneyEvent.A_OFF_ROUTE
                    evd.reason = JourneyEvent.R_SERVICE
                    api.bgEvents.postEvent("JourneyStopPosting", data: evd)
                    // TODO: This is wrong!
                    let eventData = MainEventData()
                    api.uiEvents.postEvent("ServerLogout", data: eventData)
                }
            }
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}