//
//  EventsController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/15/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class PostEventListener : BuspassPostListener {
    weak var dispatchQ : dispatch_queue_t?
    weak var eventQ : BuspassEventDistributor?
    var queueTime : TimeValue64
    var queueCount : Int
    var queueSize : Int
    
    init(dispatchQ : dispatch_queue_t, eventQ : BuspassEventDistributor) {
        self.dispatchQ = dispatchQ
        self.eventQ = eventQ
        self.queueTime = UtilsTime.current()
        self.queueCount = 0
        self.queueSize = 0
    }
    
    func unregister() {
        self.dispatchQ = nil
        self.eventQ = nil
    }
    
    func onPostEvent(event: BuspassEvent) {
        self.queueSize += 1
        if dispatchQ != nil {
            dispatch_async(dispatchQ!, {
                let start_time = UtilsTime.current()
                let tdiff = self.queueTime - start_time
                self.eventQ?.rollAll()
                self.queueCount += 1
                self.queueTime = UtilsTime.current()
                self.queueSize -= 1
                let end_time = UtilsTime.current()
                let spent = end_time - start_time
            })
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}

class EventsController {
    var eventControllers : [BuspassEventDistributor] = [BuspassEventDistributor]()
    var bgQueue : dispatch_queue_t = dispatch_queue_create("background", DISPATCH_QUEUE_SERIAL)
    var fgQueue : dispatch_queue_t = dispatch_get_main_queue()
    
    init() {
        
    }
    
    func register(api : EventsApi) {
        eventControllers.append(api.uiEvents)
        eventControllers.append(api.bgEvents)
        
        api.uiEvents.postEventListener = PostEventListener(dispatchQ: fgQueue, eventQ: api.uiEvents)
        api.bgEvents.postEventListener = PostEventListener(dispatchQ: bgQueue, eventQ: api.bgEvents)
    }
    
    func unregister(api : EventsApi) {
        api.uiEvents.postEventListener = nil
        api.bgEvents.postEventListener = nil
        api.uiEvents.disable()
        api.bgEvents.disable()
        if BLog.DEBUG && api.uiEvents.eventNotifiers.count > 0 {
            BLog.logger.debug("\(api.uiEvents.name) \(api.uiEvents.eventNotifiers.count) is greater than zero")
            for (key, notifier) in api.uiEvents.eventNotifiers {
                var s = ""
                for lis in notifier.eventListeners {
                    s += ", \(lis)"
                }
                BLog.logger.debug("\(notifier.eventName) \(notifier.eventListeners.count): \(s)")
            }
        } else {
            if BLog.DEALLOC { BLog.logger.debug("\(api.uiEvents.name) has no listeners! UNREGISTERED") }
        }
        if BLog.DEBUG && api.bgEvents.eventNotifiers.count > 0 {
            BLog.logger.debug("\(api.bgEvents.name) \(api.bgEvents.eventNotifiers.count) is greater than zero")
            for (key, notifier) in api.bgEvents.eventNotifiers {
                var s = ""
                for lis in notifier.eventListeners {
                    s += ", \(lis)"
                }
                BLog.logger.debug("\(notifier.eventName) \(notifier.eventListeners.count): \(s)")
            }

        } else {
            if BLog.DEALLOC { BLog.logger.debug("\(api.bgEvents.name) has no listeners! UNREGISTERED") }
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }

}