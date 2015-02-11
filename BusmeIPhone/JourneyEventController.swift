//
//  JourneyEventController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class JourneyEventController : BuspassEventListener {
    var api : BuspassApi
    
    init( api : BuspassApi) {
        self.api = api
        api.uiEvents.registerForEvent("JourneyEvent", listener: self)
    }
    
    func unregisterForEvents() {
        api.uiEvents.unregisterForEvent("JourneyEvent", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventData = event.eventData as? JourneyEventData
        if eventData != nil {
            switch (eventData!.action) {
            case JourneyEvent.A_ON_ROUTE_POSTING:
                onRoutePosting(eventData!)
                break
            case JourneyEvent.A_AT_ROUTE_START:
                onRouteStart(eventData!)
                break
            case JourneyEvent.A_OFF_ROUTE:
                onOffRoute(eventData!)
                break
            case JourneyEvent.A_ON_ROUTE:
                onOnRoute(eventData!)
                break
            case JourneyEvent.A_UPDATE_ROUTE:
                onUpdateRoute(eventData!)
                break
            case JourneyEvent.A_AT_ROUTE_END:
                onAtRouteEnd(eventData!)
                break
            case JourneyEvent.A_ON_ROUTE_DONE:
                onOnRouteDone(eventData!)
                break
            default:
                if (BLog.ERROR) { BLog.logger.error("bad JourneyEventAction \(eventData!.action)") }
            }
        }
    }
    func onRoutePosting(eventData : JourneyEventData) {
        
    }
    
    func onRouteStart(eventData : JourneyEventData) {
        
    }
    
    func onOffRoute(eventData : JourneyEventData) {
        
    }
    
    func onOnRoute(eventData : JourneyEventData) {
        
    }
    
    func onUpdateRoute(eventData : JourneyEventData) {
        
    }
    
    func onAtRouteEnd(eventData : JourneyEventData) {
        
    }
    
    func onOnRouteEnd(eventData : JourneyEventData) {
        
    }
    
    func onOnRouteDone(eventData : JourneyEventData) {
        
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}