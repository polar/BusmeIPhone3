
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

public class BuspassEventListener {
    public func onBuspassEvent(event : BuspassEvent) {
        
    }
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

public class BuspassPostListener {
    public func onPostEvent(event : BuspassEvent) {
    }
}

public class BuspassEventDistributor {
    public var name : String
    public var postEventListener : BuspassPostListener?
    public var eventNotifiers : [String:[BuspassEventNotifier]] = [String:[BuspassEventNotifier]]();
    public var eventQ : [BuspassEvent] = [BuspassEvent]();

    public init(name : String) {
        self.name = name
    }
    
    public func postBuspassEvent(event : BuspassEvent) {
        eventQ.insert(event, atIndex: 0);
        if (postEventListener != nil) {
            postEventListener!.onPostEvent(event);
        }
    }

    public func postEvent(eventName : String) {
        let event = BuspassEvent(name: eventName, data: nil)
        postBuspassEvent(event)
    }
    
    public func postEvent(eventName : String, data : AnyObject) {
        let event = BuspassEvent(name: eventName, data: data)
        postBuspassEvent(event)
    }
    
    public func peek() -> BuspassEvent? {
        return eventQ.last;
    }
    
    public func top() -> BuspassEvent? {
        return peek();
    }
    
    public func roll() -> BuspassEvent? {
        let event : BuspassEvent? = self.eventQ.removeLast();
        if (event != nil) {
            let notifiers = eventNotifiers[event!.eventName]
            if (notifiers != nil) {
                for notifier in notifiers! {
                    notifier.notifyEventListeners(event!)
                }
            }
            return event!
        }
        return event
    }
    
    public func rollAll() {
        var event = roll();
        while (event != nil) {
            event = roll()
        }
    }
}