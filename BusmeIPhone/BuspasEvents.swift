
//
//  BuspasEvents.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/4/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class BuspassEvent {
    var eventName : String;
    var eventData : AnyObject?;
    
    init(name : String, data: AnyObject?) {
        self.eventName = name;
        self.eventData = data;
    }
}

protocol BuspassEventListener : class {
    func onBuspassEvent(event : BuspassEvent)
}

class BuspassEventNotifier {
    var eventName : String;
    var eventListeners : [BuspassEventListener] = [BuspassEventListener]();
    
    init(name : String) {
        self.eventName = name
    }
    
    func register(listener : BuspassEventListener) {
        self.eventListeners.append(listener);
    }
    
    func unregister(listener : BuspassEventListener) {
        // We got big problems if this doesn't get rid of references.
        //self.eventListeners = self.eventListeners.filter({(x : BuspassEventListener) in listener !== x});
        var found = false
        do {
            found = false
            var index = 0
            for lis in eventListeners {
                if lis === listener {
                    if BLog.DEBUG { BLog.logger.debug("removing \(lis) from \(eventName)") }
                    eventListeners.removeAtIndex(index)
                    found = true
                    break
                }
                index += 1
            }
            
        } while found;
    }
    
    func reset() {
        self.eventListeners = [BuspassEventListener]();
    }
    
    func notifyEventListeners(event: BuspassEvent) {
        for listener in eventListeners {
            listener.onBuspassEvent(event)
        }
    }
}

protocol BuspassPostListener : class {
    func onPostEvent(event : BuspassEvent)
}

class BuspassEventDistributor {
    var name : String
    // This cannot be weak.
    var postEventListener : BuspassPostListener?
    var eventNotifiers : [String:BuspassEventNotifier] = [String:BuspassEventNotifier]();
    var eventQ : [BuspassEvent] = [BuspassEvent]();
    var enabled = true

    var writeLock : dispatch_semaphore_t
    
    init(name : String) {
        self.name = name
        self.writeLock = dispatch_semaphore_create(1)
    }
    
    func registerForEvent(eventName : String, listener : BuspassEventListener) {
        if enabled {
            var notifier = eventNotifiers[eventName]
            if notifier == nil {
                notifier = BuspassEventNotifier(name: eventName)
                eventNotifiers[eventName] = notifier
            }
            notifier!.register(listener)
        } else {
            if BLog.DEBUG { BLog.logger.debug("disabled") }
        }
    }
    
    func unregisterForEvent(eventName : String, listener : BuspassEventListener) {
        var notifier = eventNotifiers[eventName]
        if notifier != nil {
            notifier!.unregister(listener)
            if notifier!.eventListeners.count == 0 {
                eventNotifiers[eventName] = nil
            }
        }
    }
    
    func postBuspassEvent(event : BuspassEvent) {
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        if enabled {
            
            if (BLog.DEBUG) { BLog.logger.debug("\(name):post \(event.eventName)") }

            eventQ.insert(event, atIndex: 0);
            
            dispatch_semaphore_signal(writeLock)
            
            if (postEventListener != nil) {
                postEventListener!.onPostEvent(event);
            }
        } else {
            if (BLog.DEBUG) { BLog.logger.debug("\(name): disabled") }
            dispatch_semaphore_signal(writeLock)
        }
    }
    
    func postEvent(eventName : String, data : AnyObject) {
        let event = BuspassEvent(name: eventName, data: data)
        postBuspassEvent(event)
    }
    
    func peek() -> BuspassEvent? {
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        let last = eventQ.last
        dispatch_semaphore_signal(writeLock)

        return last;
    }
    
    func top() -> BuspassEvent? {
        return peek();
    }
    
    func roll() -> BuspassEvent? {
        // fatal error: cannot remove last from empty array.
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        if self.eventQ.count > 0 {
            let event : BuspassEvent? = self.eventQ.removeLast();
            dispatch_semaphore_signal(writeLock)
            if (event != nil) {
                let notifier = eventNotifiers[event!.eventName]
                if (notifier != nil) {
                    notifier!.notifyEventListeners(event!)
                }
                return event!
            }
        } else {
            dispatch_semaphore_signal(writeLock)
        }
        return nil
    }
    
    func rollAll() {
        var event = roll();
        while (event != nil) {
            event = roll()
        }
    }
    
    func disable() {
        dispatch_semaphore_signal(writeLock)
        enabled = false
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("\(name): disable \(eventQ.count) events will be deallocated") }
        eventQ = [BuspassEvent]()
        dispatch_semaphore_signal(writeLock)
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC \(name)") }
    }
}