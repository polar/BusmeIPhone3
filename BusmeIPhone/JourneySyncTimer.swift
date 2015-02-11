//
//  JourneySyncTimer.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/16/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class JourneySyncTimer : NSObject, BuspassEventListener {
    weak var masterController : MasterController?
    var pleaseStop : Bool = false
    
    init(masterController : MasterController) {
        self.masterController = masterController
        super.init()
        masterController.api.uiEvents.registerForEvent("JourneySyncProgress", listener: self)
    }
    
    func unregisterForEvents() {
        masterController?.api.uiEvents.unregisterForEvent("JourneySyncProgress", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventName = event.eventName
        if eventName == "JourneySyncProgress" {
            let eventData = event.eventData as JourneySyncProgressEventData
            if eventData.action == JourneySyncProgressEvent.P_DONE {
                if !pleaseStop {
                    scheduleUpdate(masterController!.api.syncRate/1000)
                }
            }
        }
    }
    
    func start(isForced : Bool) {
        self.pleaseStop = false
        postUpdate(isForced)
    }
    
    func stop() {
        self.pleaseStop = true
    }
    
    func postUpdate(isForced : Bool) {
        let evd = JourneySyncEventData(isForced: isForced)
        masterController?.api.bgEvents.postEvent("JourneySync", data: evd)
    }
    
    func scheduleUpdate(interval : Int) {
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(interval),
            target: self,
            selector: "doTimedUpdate",
            userInfo: nil,
            repeats: false)
    }
    
    func doTimedUpdate() {
        if !pleaseStop {
            postUpdate(false)
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }

}