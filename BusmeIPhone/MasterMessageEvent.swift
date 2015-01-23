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
    public var time : TimeValue64 = 0
    
    public init(masterMessage : MasterMessage) {
        self.masterMessage = masterMessage
    }
    
    public func dup() -> MasterMessageEventData {
        let evd = MasterMessageEventData(masterMessage: masterMessage)
        evd.state = state
        evd.resolve = resolve
        evd.thruUrl = thruUrl
        evd.resolveData = resolveData
        evd.time = time
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
    weak var masterMessagePresentationController : MasterMessagePresentationController?
    
    public init(api: BuspassApi) {
        self.api = api
        self.api.uiEvents.registerForEvent("MasterMessageEvent", listener: self)
    }
    
    func unregisterForEvents() {
        self.api.uiEvents.unregisterForEvent("MasterMessageEvent", listener: self)
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
        let time = eventData.time != 0 ? eventData.time : UtilsTime.current()
        switch(eventData.resolve) {
        case MasterMessageEvent.R_CANCEL:
            masterMessagePresentationController?.onDismiss(true, masterMessage: masterMessage, time: time)
            break;
        case MasterMessageEvent.R_GO:
            let evd = eventData.dup()
            api.bgEvents.postEvent("MasterMessageEvent", data: evd)
            break;
        case MasterMessageEvent.R_REMIND:
            masterMessagePresentationController?.onDismiss(true, masterMessage: masterMessage, time: time)

            break;
        case MasterMessageEvent.R_REMOVE:
            masterMessagePresentationController?.onDismiss(false, masterMessage: masterMessage, time: time)

            break;
        default:
            break;
        }
    }
    
    // From the MasterMessageBackground Thread
    func onResolved(eventData : MasterMessageEventData) {
        let evd = eventData.dup()
        api.uiEvents.postEvent("MasterMessagePresent:webDisplay", data: evd)
        evd.state = MasterMessageEvent.S_DONE
        api.bgEvents.postEvent("MasterMessageEvent", data: evd)
    }
    
    func onError(eventData : MasterMessageEventData) {
    }
    
    func onDone(eventData : MasterMessageEventData) {
        if BLog.DEBUG { BLog.logger.debug("MasterMessageEvent DONE \(eventData.masterMessage.title)") }
    }
}

public class MasterMessageBackground : BuspassEventListener {
    public var api : BuspassApi
    
    public init(api : BuspassApi) {
        self.api = api
        self.api.bgEvents.registerForEvent("MasterMessageEvent", listener: self)
    }
    
    func unregisterForEvents() {
        self.api.bgEvents.unregisterForEvent("MasterMessageEvent", listener: self)
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
        let evd = eventData.dup()
        evd.state = MasterMessageEvent.S_ERROR
        api.uiEvents.postEvent("MasterMessageEvent", data: evd)
    }
    
    func onDone(eventData : MasterMessageEventData) {
        if BLog.DEBUG { BLog.logger.debug("MasterMessageEvent Background DONE \(eventData.masterMessage.title)") }
        
    }
}
