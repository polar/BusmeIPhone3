//
//  JourneyDisplayController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/9/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public protocol OnJourneyDisplayAddedListener {
    func onJourneyDisplayAdded(journey : JourneyDisplay)
}

public protocol OnJourneyDisplayRemovedListener {
    func onJourneyDisplayRemoved(journey : JourneyDisplay)
}

public class JourneyDisplayEventData {
    public var id : String
    public var journeyDisplay : JourneyDisplay?
    public var journeyDisplayController : JourneyDisplayController?
    
    public init(journeyDisplay : JourneyDisplay) {
        self.journeyDisplay = journeyDisplay
        self.id = journeyDisplay.route.id!
    }
    
    public init(id : String) {
        self.id = id
    }
}

public class JourneyDisplayController : OnJourneyAddedListener, OnJourneyRemovedListener {
    public var api : BuspassApi
    public var journeyBasket : JourneyBasket
    
    public var onJourneyDisplayAddedListener : OnJourneyDisplayAddedListener?
    public var onJourneyDisplayRemovedListener : OnJourneyDisplayRemovedListener?
    public var journeyDisplays = [JourneyDisplay]()
    public var journeyDisplayMap = [String:JourneyDisplay]()
    var writeLock = dispatch_semaphore_create(1)
    
    public init(api :BuspassApi, basket : JourneyBasket) {
        self.api = api
        self.journeyBasket = basket
        basket.addOnJourneyAddedListeners(self)
        basket.addOnJourneyRemovedListeners(self)
    }
    
    public func getJourneyDisplays() -> [JourneyDisplay] {
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        let result = [JourneyDisplay](journeyDisplays)
        dispatch_semaphore_signal(writeLock)
        return result
    }
    
    public func getJourneyPatterns() -> [JourneyPattern] {
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
    
    public func onJourneyAdded(journeyBasket : JourneyBasket, journey : Route) {
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
    
    public func onJourneyRemoved(journeyBasket : JourneyBasket, journey : Route) {
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
    
    
    public func presentJourneyDisplay(jd : JourneyDisplay) {
        let evd = JourneyDisplayEventData(journeyDisplay: jd)
        api.uiEvents.postEvent("JourneyAdded", data: evd)
    }
    
    public func abandonJourneyDisplay(jd : JourneyDisplay) {
        let evd = JourneyDisplayEventData(journeyDisplay: jd)
        api.uiEvents.postEvent("JourneyRemoved", data: evd)
        
    }
}