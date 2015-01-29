//
//  FGMasterMessagePresentController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/13/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreGraphics

class FGMasterMessagePresentController : BuspassEventListener {
    
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
        api.uiEvents.registerForEvent("MasterMessagePresent:display", listener: self)
        api.uiEvents.registerForEvent("MasterMessagePresent:dismiss", listener: self)
        api.uiEvents.registerForEvent("MasterMessagePresent:webDisplay", listener: self)
    }
    
    
    func unregisterForEvents() {
        api.uiEvents.unregisterForEvent("MasterMessagePresent:display", listener: self)
        api.uiEvents.unregisterForEvent("MasterMessagePresent:dismiss", listener: self)
        api.uiEvents.unregisterForEvent("MasterMessagePresent:webDisplay", listener: self)
    }
    
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventData = event.eventData as? MasterMessageEventData
        if eventData != nil {
            if event.eventName == "MasterMessagePresent:display" {
                presentMasterMessage(eventData!);
            } else if event.eventName == "MasterMessagePresent:dismiss" {
                abandonMasterMessage(eventData!);
            } else if event.eventName == "MasterMessagePresent:webDisplay" {
                onWebDisplay(eventData!);
            }
        }
    }
    private var currentMasterMessage : MasterMessageViewController?
    
    func presentMasterMessage(eventData : MasterMessageEventData) {
        let masterMessage = eventData.masterMessage
        let mvc = MasterMessageViewController(masterMapScreen: masterMapScreen, masterMessage: masterMessage)
        currentMasterMessage = mvc
        mvc.display()
    }
    
    func onWebDisplay(eventData : MasterMessageEventData) {
        if currentMasterMessage != nil {
            if (currentMasterMessage!.masterMessage === eventData.masterMessage) {
                currentMasterMessage!.displayWebPage(eventData.thruUrl)
                eventData.state = MasterMessageEvent.S_DONE
                api.uiEvents.postEvent("MasterMessageEvent", data: eventData)
            }
        }
    }
    
    func abandonMasterMessage(eventData : MasterMessageEventData) {
        let masterMessage = eventData.masterMessage
        if currentMasterMessage != nil {
            currentMasterMessage!.dismiss()
        } else {
            let evd = eventData.dup()
            evd.state = MasterMessageEvent.S_DONE
            evd.time = UtilsTime.current()
            api.uiEvents.postEvent("MasterMessageEvent", data: eventData)
        }
    }
}
