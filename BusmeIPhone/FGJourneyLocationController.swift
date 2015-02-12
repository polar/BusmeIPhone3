//
//  FGJourneyLocationPresentController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/13/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreGraphics

class JourneyDisplayLocationEventData {
    var journeyLocation : JourneyLocation
    var journeyDisplay : JourneyDisplay
    init(journeyLocation : JourneyLocation, journeyDisplay : JourneyDisplay) {
        self.journeyLocation = journeyLocation
        self.journeyDisplay = journeyDisplay
    }
}

class FGJourneyLocationPresentController : BuspassEventListener {
    
    weak var api : BuspassApi!
    weak var masterMapScreen : MasterMapScreen!
    weak var masterController : MasterController!
    
    init(masterMapScreen : MasterMapScreen) {
        self.masterMapScreen = masterMapScreen
        self.masterController = masterMapScreen.masterController
        self.api = masterMapScreen.api
        registerForEvents()
        
    }
    
    func registerForEvents() {
        api.uiEvents.registerForEvent("JourneyLocationPresent:display", listener: self)
        api.uiEvents.registerForEvent("JourneyLocationPresent:dismiss", listener: self)
        api.uiEvents.registerForEvent("JourneyLocationPresent:webDisplay", listener: self)
    }
    
    
    func unregisterForEvents() {
        api.uiEvents.unregisterForEvent("JourneyLocationPresent:display", listener: self)
        api.uiEvents.unregisterForEvent("JourneyLocationPresent:dismiss", listener: self)
        api.uiEvents.unregisterForEvent("JourneyLocationPresent:webDisplay", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventData = event.eventData as? JourneyDisplayLocationEventData
        if eventData != nil {
            if event.eventName == "JourneyLocationPresent:display" {
                presentJourneyLocation(eventData!);
            } else if event.eventName == "JourneyLocationPresent:dismiss" {
                abandonJourneyLocation(eventData!);
            }
        }
    }
    
    private var currentJourneyLocations : [String:JourneyLocationAnnotation] = [String:JourneyLocationAnnotation]()
    func presentJourneyLocation(eventData : JourneyDisplayLocationEventData) {
        let journeyLocation = eventData.journeyLocation
        let journeyDisplay = eventData.journeyDisplay
        let annotation = JourneyLocationAnnotation(journeyDisplay: journeyDisplay, journeyLocation: journeyLocation)
        currentJourneyLocations[journeyDisplay.route.id!] = annotation
        //masterMapScreen.addJourneyLocationAnnotation(annotation)
    }
    
    func abandonJourneyLocation(eventData : JourneyDisplayLocationEventData) {
        let journeyLocation = eventData.journeyLocation
        let journeyDisplay = eventData.journeyDisplay
        let annotation = currentJourneyLocations[journeyDisplay.route.id!]
        if annotation != nil {
           // masterMapScreen.removeJourneyLocationAnnotation(annotation!)
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}
