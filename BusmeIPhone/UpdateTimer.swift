//
//  UpdateTimer.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/16/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class UpdateTimer : BuspassEventListener {
    var masterController : MasterController
    var pleaseStop : Bool = false
    
    init(masterController : MasterController) {
        self.masterController = masterController
        masterController.api.uiEvents.registerForEvent("UpdateProgress", listener: self)
    }
    
    func unregisterForEvents() {
        masterController.api.uiEvents.unregisterForEvent("UpdateProgress", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventName = event.eventName
        
        // Main Thread
        if eventName == "UpdateProgress" {
            let eventData = event.eventData as UpdateProgressEventData
            switch(eventData.action) {
            case InvocationProgressEvent.U_FINISH:
                if !pleaseStop {
                    scheduleUpdate(masterController.api.updateRate)
                }
                break
            default:
                break
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
        masterController.api.bgEvents.postEvent("Update", data: UpdateEventData(isForced: isForced))
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