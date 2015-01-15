//
//  EventsController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/15/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class PostEventListener : BuspassPostListener {
    var dispatchQ : dispatch_queue_t?
    var eventQ : BuspassEventDistributor?
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
    }
}