//
//  JourneySyncTimer.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/16/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class JourneySyncTimer : BuspassEventListener {
    var masterController : MasterController
    var pleaseStop : Bool = false
    
    init(masterController : MasterController) {
        self.masterController = masterController
        masterController.api.uiEvents.registerForEvent("JourneySyncProgress", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventName = event.eventName
        if eventName == "JourneySyncProgess" {
            let eventData = event.eventData as JourneySyncProgressEventData
            if eventData.action == JourneySyncProgressEvent.P_DONE {
                scheduleUpdate(masterController.api.syncRate)
            }
        }
    }
    
    func start(isForced : Bool) {
        self.pleaseStop = true
        postUpdate(isForced)
    }
    
    func stop() {
        self.pleaseStop = true
    }
    
    func postUpdate(isForced : Bool) {
        let evd = JourneySyncEventData(isForced: isForced)
        masterController.api.bgEvents.postEvent("JourneySync", data: evd)
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

}