//
//  JourneyEventController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class JourneyEventController : BuspassEventListener {
    public var api : BuspassApi
    
    public init( api : BuspassApi) {
        self.api = api
        api.uiEvents.registerForEvent("JourneyEvent", listener: self)
    }
    
    func unregisterForEvents() {
        api.uiEvents.unregisterForEvent("JourneyEvent", listener: self)
    }
    
    public func onBuspassEvent(event: BuspassEvent) {
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
    public func onRoutePosting(eventData : JourneyEventData) {
        
    }
    
    public func onRouteStart(eventData : JourneyEventData) {
        
    }
    
    public func onOffRoute(eventData : JourneyEventData) {
        
    }
    
    public func onOnRoute(eventData : JourneyEventData) {
        
    }
    
    public func onUpdateRoute(eventData : JourneyEventData) {
        
    }
    
    public func onAtRouteEnd(eventData : JourneyEventData) {
        
    }
    
    public func onOnRouteEnd(eventData : JourneyEventData) {
        
    }
    
    public func onOnRouteDone(eventData : JourneyEventData) {
        
    }
}