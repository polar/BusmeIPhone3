//
//  MasterMessageEvent.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public struct MasterMessageEvent {
    public static let S_PRESENT  = 0
    public static let S_RESOLVE  = 1
    public static let S_RESOLVED = 2
    public static let S_ERROR    = 3
    public static let S_DONE     = 4
    
    public static let R_GO     = 1
    public static let R_REMIND = 2
    public static let R_REMOVE = 3
    public static let R_CANCEL = 4
}

public class MasterMessageEventData {
    public var state : Int = MasterMessageEvent.S_PRESENT
    public var thruUrl : String?
    public var masterMessage : MasterMessage
    public var resolve : Int = MasterMessageEvent.R_CANCEL
    public var resolveData : AnyObject?
    
    public init(masterMessage : MasterMessage) {
        self.masterMessage = masterMessage
    }
    
    public func dup() -> MasterMessageEventData {
        let evd = MasterMessageEventData(masterMessage: masterMessage)
        evd.state = state
        evd.resolve = resolve
        evd.thruUrl = thruUrl
        evd.resolveData = resolveData
        return evd
    }
    
    public func empty() {
        //self.masterMessage = nil
        self.thruUrl = nil
        self.resolveData = nil
    }
    
}

public class MasterMessageForeground : BuspassEventListener {
    public var api : BuspassApi
    
    public init(api: BuspassApi) {
        self.api = api
        self.api.uiEvents.registerForEvent("MasterMessageEvent", listener: self)
    }
    
    public func onBuspassEvent(event: BuspassEvent) {
        let evd = event.eventData as MasterMessageEventData
        switch(evd.state) {
        case MasterMessageEvent.S_PRESENT:
            onPresent(evd)
            break
        case MasterMessageEvent.S_RESOLVE:
            onResolve(evd)
            break
        case MasterMessageEvent.S_RESOLVED:
            onResolved(evd)
            break
        case MasterMessageEvent.S_ERROR:
            onError(evd)
            break
        case MasterMessageEvent.S_DONE:
            onDone(evd)
            break
        default:
            break
        }
    }
    
    func onPresent(eventData : MasterMessageEventData) {
        eventData.masterMessage.onDisplay(UtilsTime.current())
        // Should display the message on screen.
        api.uiEvents.postEvent("MasterMessagePresent:display", data: eventData)
    }
    
    // From the MasterMessage click, MasterMessagePresentationController sends this event.
    
    func onResolve(eventData : MasterMessageEventData) {
        let masterMessage = eventData.masterMessage
        
        switch(eventData.resolve) {
        case MasterMessageEvent.R_CANCEL:
            break;
        case MasterMessageEvent.R_GO:
            let evd = eventData.dup()
            api.bgEvents.postEvent("MasterMessageEvent", data: evd)
            break;
        case MasterMessageEvent.R_REMIND:
            masterMessage.onDismiss(true)
            api.uiEvents.postEvent("MasterMessagePresent:dismiss", data: eventData)
            break;
        case MasterMessageEvent.R_REMOVE:
            masterMessage.onDismiss(false)
            api.uiEvents.postEvent("MasterMessagePresent:dismiss", data: eventData)
            break;
        default:
            break;
        }
    }
    
    // From the MasterMessageBackground Thread
    func onResolved(eventData : MasterMessageEventData) {
        switch(eventData.resolve) {
        case MasterMessageEvent.R_CANCEL:
            break
        case MasterMessageEvent.R_GO:
            break
        case MasterMessageEvent.R_REMIND:
            break
        case MasterMessageEvent.R_REMOVE:
            break
        default:
            break
        }
        let evd = eventData.dup()
        evd.state = MasterMessageEvent.S_DONE
        api.bgEvents.postEvent("MasterMessageEvent", data: evd)
    }
    
    func onError(eventData : MasterMessageEventData) {
    }
    
    func onDone(eventData : MasterMessageEventData) {
    }
}

public class MasterMessageBackground : BuspassEventListener {
    public var api : BuspassApi
    
    public init(api : BuspassApi) {
        self.api = api
        self.api.bgEvents.registerForEvent("MasterMessageEvent", listener: self)
    }
    
    public func onBuspassEvent(event: BuspassEvent) {
        let evd = event.eventData! as MasterMessageEventData
        switch(evd.state) {
        case MasterMessageEvent.S_RESOLVE:
            onResolve(evd)
            break
        case MasterMessageEvent.S_ERROR:
            onError(evd)
            break
        case MasterMessageEvent.S_DONE:
            onDone(evd)
            break
        default:
            break
        }
    }
    
    func onResolve(eventData : MasterMessageEventData) {
        let evd = eventData.dup()
        switch(eventData.resolve) {
        case MasterMessageEvent.R_GO:
            var url = api.getMasterMessageClickThru(eventData.masterMessage.id)
            if (url == nil) {
                url = eventData.masterMessage.goUrl
            }
            evd.thruUrl = url
            break
        case MasterMessageEvent.R_REMIND:
            break
        case MasterMessageEvent.R_REMOVE:
            break
        case MasterMessageEvent.R_CANCEL:
            break
        default:
            break
        }
        evd.state = MasterMessageEvent.S_RESOLVED
        api.uiEvents.postEvent("MasterMessageEvent", data: evd)
    }
    
    func onError(eventData : MasterMessageEventData) {
        api.uiEvents.postEvent("MasterMessageEvent", data: eventData)
    }
    
    func onDone(eventData : MasterMessageEventData) {
        api.uiEvents.postEvent("MasterMessageEvent", data: eventData)
    }
}
