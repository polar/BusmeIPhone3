//
//  JourneyDisplayController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/9/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

protocol OnJourneyDisplayAddedListener : class {
    func onJourneyDisplayAdded(journey : JourneyDisplay)
}

protocol OnJourneyDisplayRemovedListener : class {
    func onJourneyDisplayRemoved(journey : JourneyDisplay)
}

class JourneyDisplayEventData {
    var id : String
    var journeyDisplay : JourneyDisplay?
    var journeyDisplayController : JourneyDisplayController?
    
    init(journeyDisplay : JourneyDisplay) {
        self.journeyDisplay = journeyDisplay
        self.id = journeyDisplay.route.id!
    }
    
    init(id : String) {
        self.id = id
    }
}

class JourneyDisplayController : OnJourneyAddedListener, OnJourneyRemovedListener, BuspassEventListener {
    unowned var api : BuspassApi
    unowned var journeyBasket : JourneyBasket
    
    weak var onJourneyDisplayAddedListener : OnJourneyDisplayAddedListener?
    weak var onJourneyDisplayRemovedListener : OnJourneyDisplayRemovedListener?
    var journeyDisplays = [JourneyDisplay]()
    var journeyDisplayMap = [String:JourneyDisplay]()
    var writeLock = dispatch_semaphore_create(1)
    
    init(api :BuspassApi, basket : JourneyBasket) {
        self.api = api
        self.journeyBasket = basket
        basket.addOnJourneyAddedListeners(self)
        basket.addOnJourneyRemovedListeners(self)
        registerForEvents()
    }
    
    func registerForEvents() {
        api.uiEvents.registerForEvent("LocationChanged", listener: self)
    }
    
    func unregisterForEvents() {
        api.uiEvents.unregisterForEvent("LocationChanged", listener: self)
    }
    
    var currentLocation : GeoPoint?
    func onBuspassEvent(event: BuspassEvent) {
        let eventData = event.eventData as LocationEventData
        currentLocation = GeoPointImpl(lat: eventData.location.latitude, lon: eventData.location.longitude)
    }
    
    func getJourneyDisplays() -> [JourneyDisplay] {
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        let result = [JourneyDisplay](journeyDisplays)
        dispatch_semaphore_signal(writeLock)
        return result
    }
    
    func getJourneyPatterns() -> [JourneyPattern] {
        var patterns = [String:JourneyPattern]()
        for jd in getJourneyDisplays() {
            if jd.route.isRouteDefinition() {
                for pat in jd.route.getJourneyPatterns() {
                    patterns[pat.id] = pat
                }
            }
        }
        return patterns.values.array
    }
    
    func onJourneyAdded(journeyBasket : JourneyBasket, journey : Route) {
        let newRoute = JourneyDisplay(journeyDisplayController: self, route: journey)
        
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        journeyDisplays.append(newRoute)
        journeyDisplayMap[journey.id!] = newRoute
        dispatch_semaphore_signal(writeLock)
        
        onJourneyDisplayAddedListener?.onJourneyDisplayAdded(newRoute)
        presentJourneyDisplay(newRoute)
    }
    
    private func removeFromJourneys(journeyDisplay : JourneyDisplay) {
        for(var i = 0; i < journeyDisplays.count; i++) {
            if (journeyDisplays[i] === journeyDisplay) {
                journeyDisplays.removeAtIndex(i)
            }
        }
    }
    
    func onJourneyRemoved(journeyBasket : JourneyBasket, journey : Route) {
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)

        let jd = journeyDisplayMap[journey.id!]
        if (jd != nil) {
            journeyDisplayMap[journey.id!] = nil
            removeFromJourneys(jd!)
            dispatch_semaphore_signal(writeLock)
            
            onJourneyDisplayRemovedListener?.onJourneyDisplayRemoved(jd!)
            abandonJourneyDisplay(jd!)
        } else {
            dispatch_semaphore_signal(writeLock)
        }

    }
    
    
    func presentJourneyDisplay(jd : JourneyDisplay) {
        let evd = JourneyDisplayEventData(journeyDisplay: jd)
        api.uiEvents.postEvent("JourneyAdded", data: evd)
    }
    
    func abandonJourneyDisplay(jd : JourneyDisplay) {
        let evd = JourneyDisplayEventData(journeyDisplay: jd)
        api.uiEvents.postEvent("JourneyRemoved", data: evd)
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}