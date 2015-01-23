//
//  MarkerEvent.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public struct MarkerEvent {
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

public class MarkerEventData {
    public var state : Int = MarkerEvent.S_PRESENT
    public var thruUrl : String?
    public var markerInfo : MarkerInfo
    public var resolve : Int = MarkerEvent.R_CANCEL
    public var resolveData : AnyObject?
    public var time : TimeValue64 = 0

    
    public init(markerInfo : MarkerInfo) {
        self.markerInfo = markerInfo
    }
    
    public func dup() -> MarkerEventData {
        let evd = MarkerEventData(markerInfo: markerInfo)
        evd.state = state
        evd.resolve = resolve
        evd.thruUrl = thruUrl
        evd.resolveData = resolveData
        evd.time = time
        return evd
    }
    
    public func empty() {
        //self.markerInfo = nil
        self.thruUrl = nil
        self.resolveData = nil
    }
    
}

public class MarkerForeground : BuspassEventListener {
    public var api : BuspassApi
    weak var markerPresentationController : MarkerPresentationController?
    
    public init(api: BuspassApi) {
        self.api = api
        self.api.uiEvents.registerForEvent("MarkerEvent", listener: self)
    }
    
    func unregisterForEvents() {
        self.api.uiEvents.unregisterForEvent("MarkerEvent", listener: self)
    }
    
    public func onBuspassEvent(event: BuspassEvent) {
        let evd = event.eventData as MarkerEventData
        switch(evd.state) {
        case MarkerEvent.S_PRESENT:
            onPresent(evd)
            break
        case MarkerEvent.S_RESOLVE:
            onResolve(evd)
            break
        case MarkerEvent.S_RESOLVED:
            onResolved(evd)
            break
        case MarkerEvent.S_ERROR:
            onError(evd)
            break
        case MarkerEvent.S_DONE:
            onDone(evd)
            break
        default:
            break
        }
    }
    
    func onPresent(eventData : MarkerEventData) {
        eventData.markerInfo.onDisplay(UtilsTime.current())
        api.uiEvents.postEvent("MarkerPresent:display", data: eventData)
    }
    
    // From the Marker click, MarkerPresentationController sends this event.
    
    func onResolve(eventData : MarkerEventData) {
        let markerInfo = eventData.markerInfo
        let time = eventData.time != 0 ? eventData.time : UtilsTime.current()
        
        switch(eventData.resolve) {
        case MarkerEvent.R_CANCEL:
            markerPresentationController?.onDismiss(true, markerInfo: markerInfo, time: time)
            break;
        case MarkerEvent.R_GO:
            let evd = eventData.dup()
            api.bgEvents.postEvent("MarkerEvent", data: evd)
            break;
        case MarkerEvent.R_REMIND:
            markerPresentationController?.onDismiss(true, markerInfo: markerInfo, time: time)
            api.uiEvents.postEvent("MarkerEvent", data: eventData)
            break;
        case MarkerEvent.R_REMOVE:
            markerPresentationController?.onDismiss(false, markerInfo: markerInfo, time: time)
            api.uiEvents.postEvent("MarkerEvent", data: eventData)
            break;
        default:
            break;
        }
    }
    
    // From the MarkerBackground Thread
    func onResolved(eventData : MarkerEventData) {
        let evd = eventData.dup()
        api.uiEvents.postEvent("MarkerPresent:webDisplay", data: evd)
        evd.state = MasterMessageEvent.S_DONE
        api.bgEvents.postEvent("MarkerEvent", data: evd.dup())
    }
    
    func onError(eventData : MarkerEventData) {
        let markerInfo = eventData.markerInfo
        let time = eventData.time != 0 ? eventData.time : UtilsTime.current()
        markerPresentationController?.onDismiss(false, markerInfo: markerInfo, time: time)
    }
    
    func onDone(eventData : MarkerEventData) {
        let markerInfo = eventData.markerInfo
        let time = eventData.time != 0 ? eventData.time : UtilsTime.current()
        if BLog.DEBUG { BLog.logger.debug("MarkerEvent DONE \(eventData.markerInfo.title)") }
        markerPresentationController?.onDismiss(false, markerInfo: markerInfo, time: time)

    }
}

public class MarkerBackground : BuspassEventListener {
    public var api : BuspassApi
    
    public init(api : BuspassApi) {
        self.api = api
        self.api.bgEvents.registerForEvent("MarkerEvent", listener: self)
    }
    
    func unregisterForEvents() {
        self.api.bgEvents.unregisterForEvent("MarkerEvent", listener: self)
    }
    
    public func onBuspassEvent(event: BuspassEvent) {
        let evd = event.eventData! as MarkerEventData
        switch(evd.state) {
        case MarkerEvent.S_RESOLVE:
            onResolve(evd)
            break
        case MarkerEvent.S_ERROR:
            onError(evd)
            break
        case MarkerEvent.S_DONE:
            onDone(evd)
            break
        default:
            break
        }
    }
    
    func onResolve(eventData : MarkerEventData) {
        let evd = eventData.dup()
        switch(eventData.resolve) {
        case MarkerEvent.R_GO:
            var url = api.getMarkerClickThru(eventData.markerInfo.id)
            if (url == nil) {
                url = eventData.markerInfo.goUrl
            }
            evd.thruUrl = url
            break
        case MarkerEvent.R_REMIND:
            break
        case MarkerEvent.R_REMOVE:
            break
        case MarkerEvent.R_CANCEL:
            break
        default:
            break
        }
        evd.state = MarkerEvent.S_RESOLVED
        api.uiEvents.postEvent("MarkerEvent", data: evd)
    }
    
    func onError(eventData : MarkerEventData) {
        let evd = eventData.dup()
        evd.state = MarkerEvent.S_ERROR
        api.uiEvents.postEvent("MarkerEvent", data: evd)
    }
    
    func onDone(eventData : MarkerEventData) {
        if BLog.DEBUG { BLog.logger.debug("MasterMessageEvent Background DONE \(eventData.markerInfo.title)") }
    }
}
