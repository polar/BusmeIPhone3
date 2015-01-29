//
//  MasterMessageEvent.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

struct MasterMessageEvent {
    static let S_PRESENT  = 0
    static let S_RESOLVE  = 1
    static let S_RESOLVED = 2
    static let S_ERROR    = 3
    static let S_DONE     = 4
    
    static let R_GO     = 1
    static let R_REMIND = 2
    static let R_REMOVE = 3
    static let R_CANCEL = 4
}

class MasterMessageEventData {
    var state : Int = MasterMessageEvent.S_PRESENT
    var thruUrl : String?
    var masterMessage : MasterMessage
    var resolve : Int = MasterMessageEvent.R_CANCEL
    var resolveData : AnyObject?
    var time : TimeValue64 = 0
    
    init(masterMessage : MasterMessage) {
        self.masterMessage = masterMessage
    }
    
    func dup() -> MasterMessageEventData {
        let evd = MasterMessageEventData(masterMessage: masterMessage)
        evd.state = state
        evd.resolve = resolve
        evd.thruUrl = thruUrl
        evd.resolveData = resolveData
        evd.time = time
        return evd
    }
    
    func empty() {
        //self.masterMessage = nil
        self.thruUrl = nil
        self.resolveData = nil
    }
    
}

class MasterMessageForeground : BuspassEventListener {
    var api : BuspassApi
    weak var masterMessagePresentationController : MasterMessagePresentationController?
    
    init(api: BuspassApi) {
        self.api = api
        self.api.uiEvents.registerForEvent("MasterMessageEvent", listener: self)
    }
    
    func unregisterForEvents() {
        self.api.uiEvents.unregisterForEvent("MasterMessageEvent", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
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

class MasterMessageBackground : BuspassEventListener {
    var api : BuspassApi
    
    init(api : BuspassApi) {
        self.api = api
        self.api.bgEvents.registerForEvent("MasterMessageEvent", listener: self)
    }
    
    func unregisterForEvents() {
        self.api.bgEvents.unregisterForEvent("MasterMessageEvent", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
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
