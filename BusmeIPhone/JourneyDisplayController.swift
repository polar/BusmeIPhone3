//
//  JourneyDisplayController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/9/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

protocol OnJourneyDisplayAddedListener {
    func onJourneyDisplayAdded(journey : JourneyDisplay)
}

protocol OnJourneyDisplayRemovedListener {
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

class JourneyDisplayController : OnJourneyAddedListener, OnJourneyRemovedListener {
    var api : BuspassApi
    var journeyBasket : JourneyBasket
    
    var onJourneyDisplayAddedListener : OnJourneyDisplayAddedListener?
    var onJourneyDisplayRemovedListener : OnJourneyDisplayRemovedListener?
    var journeyDisplays = [JourneyDisplay]()
    var journeyDisplayMap = [String:JourneyDisplay]()
    var writeLock = dispatch_semaphore_create(1)
    
    init(api :BuspassApi, basket : JourneyBasket) {
        self.api = api
        self.journeyBasket = basket
        basket.addOnJourneyAddedListeners(self)
        basket.addOnJourneyRemovedListeners(self)
    }
    
    func getJourneyDisplays() -> [JourneyDisplay] {
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        let result = [JourneyDisplay](journeyDisplays)
        dispatch_semaphore_signal(writeLock)
        return result
    }
    
    func getJourneyPatterns() -> [JourneyPattern] {
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        var patterns = [String:JourneyPattern]()
        for jd in journeyDisplays {
            if jd.route.isRouteDefinition() {
                for pat in jd.route.getJourneyPatterns() {
                    patterns[pat.id] = pat
                }
            }
        }
        dispatch_semaphore_signal(writeLock)
        return patterns.values.array
    }
    
    func onJourneyAdded(journeyBasket : JourneyBasket, journey : Route) {
        let newRoute = JourneyDisplay(journeyDisplayController: self, route: journey)
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        journeyDisplays.append(newRoute)
        journeyDisplayMap[journey.id!] = newRoute
        onJourneyDisplayAddedListener?.onJourneyDisplayAdded(newRoute)
        presentJourneyDisplay(newRoute)
        dispatch_semaphore_signal(writeLock)
    }
    
    func removeFromJourneys(journeyDisplay : JourneyDisplay) {
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
            onJourneyDisplayRemovedListener?.onJourneyDisplayRemoved(jd!)
            abandonJourneyDisplay(jd!)
        }
        dispatch_semaphore_signal(writeLock)

    }
    
    
    func presentJourneyDisplay(jd : JourneyDisplay) {
        let evd = JourneyDisplayEventData(journeyDisplay: jd)
        api.uiEvents.postEvent("JourneyAdded", data: evd)
    }
    
    func abandonJourneyDisplay(jd : JourneyDisplay) {
        let evd = JourneyDisplayEventData(journeyDisplay: jd)
        api.uiEvents.postEvent("JourneyRemoved", data: evd)
        
    }
}