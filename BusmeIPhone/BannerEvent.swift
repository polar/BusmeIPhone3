//
//  BannerEvent.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

struct BannerEvent {
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

class BannerEventData {
    var state : Int = BannerEvent.S_PRESENT
    var thruUrl : String?
    var bannerInfo : BannerInfo
    var resolve : Int = BannerEvent.R_CANCEL
    var resolveData : AnyObject?
    var time : TimeValue64 = 0
    
    init(bannerInfo : BannerInfo) {
        self.bannerInfo = bannerInfo
    }
    
    init(bannerInfo : BannerInfo, state : Int) {
        self.bannerInfo = bannerInfo
        self.state = state
    }
    
    func dup() -> BannerEventData {
        let evd = BannerEventData(bannerInfo: bannerInfo)
        evd.state = state
        evd.resolve = resolve
        evd.thruUrl = thruUrl
        evd.resolveData = resolveData
        return evd
    }
    
    func empty() {
        //self.bannerInfo = nil
        self.thruUrl = nil
        self.resolveData = nil
    }
    
}

class BannerForeground : BuspassEventListener {
    var api : BuspassApi
    weak var bannerPresentationController : BannerPresentationController?
    
    init(api: BuspassApi) {
        self.api = api
        self.api.uiEvents.registerForEvent("BannerEvent", listener: self)
    }
    
    func unregisterForEvents() {
        self.api.uiEvents.unregisterForEvent("BannerEvent", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        let evd = event.eventData as BannerEventData
        switch(evd.state) {
        case BannerEvent.S_PRESENT:
            onPresent(evd)
            break
        case BannerEvent.S_RESOLVE:
            onResolve(evd)
            break
        case BannerEvent.S_RESOLVED:
            onResolved(evd)
            break
        case BannerEvent.S_ERROR:
            onError(evd)
            break
        case BannerEvent.S_DONE:
            onDone(evd)
            break
        default:
            break
        }
    }
    
    func onPresent(eventData : BannerEventData) {
        eventData.bannerInfo.onDisplay(UtilsTime.current())
        api.uiEvents.postEvent("BannerPresent:display", data: eventData)
    }
    
    // From the Banner click, The Banner Message is presented and then on the result
    // it sends this event.
    
    func onResolve(eventData : BannerEventData) {
        let time = eventData.time != 0 ? UtilsTime.current() : eventData.time
        let evd = eventData.dup()
        switch(eventData.state) {
        case BannerEvent.R_GO:
            // resolve should have been set. Send off to the background
            api.bgEvents.postEvent("BannerEvent", data: evd)
        default:
            bannerPresentationController?.onDismiss(true, bannerInfo: eventData.bannerInfo, time: time)
            break;
        }
    }
    
    // From the BannerBackground Thread
    func onResolved(eventData : BannerEventData) {
        let time = eventData.time != 0 ? UtilsTime.current() : eventData.time
        let evd = eventData.dup()
        bannerPresentationController?.onDismiss(true, bannerInfo: eventData.bannerInfo, time: time)
        
        evd.state = BannerEvent.S_DONE
        api.uiEvents.postEvent("BannerPresent:webDisplay", data: evd)
        api.uiEvents.postEvent("BannerPresent:dismiss", data: evd.dup())
        api.bgEvents.postEvent("BannerEvent", data: evd.dup()) // To complete protocol

    }
    
    func onError(eventData : BannerEventData) {
    }
    
    func onDone(eventData : BannerEventData) {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("BannerEvent DONE \(eventData.bannerInfo.title)") }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}

class BannerBackground : BuspassEventListener {
    var api : BuspassApi
    
    init(api : BuspassApi) {
        self.api = api
        self.api.bgEvents.registerForEvent("BannerEvent", listener: self)
    }
    
    func unregisterForEvents() {
        self.api.bgEvents.unregisterForEvent("BannerEvent", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        let evd = event.eventData! as BannerEventData
        switch(evd.state) {
        case BannerEvent.S_RESOLVE:
            onResolve(evd)
            break
        case BannerEvent.S_ERROR:
            onError(evd)
            break
        case BannerEvent.S_DONE:
            onDone(evd)
            break
        default:
            break
        }
    }
    
    func onResolve(eventData : BannerEventData) {
        let evd = eventData.dup()
        switch(eventData.resolve) {
        case BannerEvent.R_GO:
            var url = api.getBannerClickThru(eventData.bannerInfo.id)
            if (url == nil) {
                url = eventData.bannerInfo.goUrl
            }
            evd.thruUrl = url
            break
        case BannerEvent.R_REMIND:
            break
        case BannerEvent.R_REMOVE:
            break
        case BannerEvent.R_CANCEL:
            break
        default:
            break
        }
        evd.state = BannerEvent.S_RESOLVED
        api.uiEvents.postEvent("BannerEvent", data: evd)
    }
    
    func onError(eventData : BannerEventData) {
    }
    
    func onDone(eventData : BannerEventData) {
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}
