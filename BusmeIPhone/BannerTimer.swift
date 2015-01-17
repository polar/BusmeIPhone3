//
//  BannerTimer.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/16/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

class BannerTimerEventData  {
    var forced : Bool
    init(forced : Bool) {
        self.forced = forced
    }
}

class BannerTimer : UIResponder, BuspassEventListener {
    var masterController : MasterController
    var pleaseStop : Bool = false
    var interval : Int
    
    init(masterController : MasterController, interval : Int) {
        self.masterController = masterController
        self.interval = interval
        super.init()
        masterController.api.bgEvents.registerForEvent("Banner:roll", listener: self)
    }
    
    func unregisterForEvents() {
        masterController.api.bgEvents.unregisterForEvent("Banner:roll", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventName = event.eventName
        if eventName == "Banner:roll" {
            let now = UtilsTime.current()
            masterController.bannerPresentationController.roll(true, now: now)
            masterController.markerPresentationController.roll(now: now)
            masterController.masterMessagePresentationController.roll(false, now: now)
        }
    }
    
    func start() {
        self.pleaseStop = false
        doBannerUpdate(true)
    }
    
    func stop() {
        self.pleaseStop = true
    }
    
    func doBannerUpdate(forced: Bool) {
        masterController.api.bgEvents.postEvent("Banner:roll", data: BannerTimerEventData(forced: forced))
        
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(self.interval),
            target: self,
            selector: "doTimedUpdate",
            userInfo: nil,
            repeats: false)
    }
    
    func doTimedUpdate() {
        if !pleaseStop {
            doBannerUpdate(false)
        }
    }
    
}
