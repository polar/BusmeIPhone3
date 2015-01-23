
//
//  BuspasEvents.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/4/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class BuspassEvent {
    public var eventName : String;
    public var eventData : AnyObject?;
    
    public init(name : String, data: AnyObject?) {
        self.eventName = name;
        self.eventData = data;
    }
}

public protocol BuspassEventListener : class {
    func onBuspassEvent(event : BuspassEvent)
}

public class BuspassEventNotifier {
    public var eventName : String;
    public var eventListeners : [BuspassEventListener] = [BuspassEventListener]();
    
    public init(name : String) {
        self.eventName = name
    }
    
    public func register(listener : BuspassEventListener) {
        self.eventListeners.append(listener);
    }
    
    public func unregister(listener : BuspassEventListener) {
        self.eventListeners =
            self.eventListeners.filter({(x : BuspassEventListener) in listener !== x});
    }
    
    public func reset() {
        self.eventListeners = [BuspassEventListener]();
    }
    
    public func notifyEventListeners(event: BuspassEvent) {
        for listener in eventListeners {
            listener.onBuspassEvent(event)
        }
    }
}

public protocol BuspassPostListener : class {
    func onPostEvent(event : BuspassEvent)
}

public class BuspassEventDistributor {
    public var name : String
    public var postEventListener : BuspassPostListener?
    public var eventNotifiers : [String:BuspassEventNotifier] = [String:BuspassEventNotifier]();
    public var eventQ : [BuspassEvent] = [BuspassEvent]();

    var writeLock : dispatch_semaphore_t
    
    public init(name : String) {
        self.name = name
        self.writeLock = dispatch_semaphore_create(1)
    }
    
    public func registerForEvent(eventName : String, listener : BuspassEventListener) {
        var notifier = eventNotifiers[eventName]
        if notifier == nil {
            notifier = BuspassEventNotifier(name: eventName)
            eventNotifiers[eventName] = notifier
        }
        notifier!.register(listener)
    }
    
    public func unregisterForEvent(eventName : String, listener : BuspassEventListener) {
        var notifier = eventNotifiers[eventName]
        if notifier != nil {
            notifier!.unregister(listener)
        }
    }
    
    public func postBuspassEvent(event : BuspassEvent) {
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        
        if (BLog.DEBUG) { BLog.logger.debug("\(event.eventName)") }

        eventQ.insert(event, atIndex: 0);
        
        dispatch_semaphore_signal(writeLock)
        
        if (postEventListener != nil) {
            postEventListener!.onPostEvent(event);
        }
    }
    
    public func postEvent(eventName : String, data : AnyObject) {
        let event = BuspassEvent(name: eventName, data: data)
        postBuspassEvent(event)
    }
    
    public func peek() -> BuspassEvent? {
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        let last = eventQ.last
        dispatch_semaphore_signal(writeLock)

        return last;
    }
    
    public func top() -> BuspassEvent? {
        return peek();
    }
    
    public func roll() -> BuspassEvent? {
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
    
    public func rollAll() {
        var event = roll();
        while (event != nil) {
            event = roll()
        }
    }
}