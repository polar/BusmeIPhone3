//
//  JourneySyncProgressEvent.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

struct JourneySyncProgressEvent {
    static let P_BEGIN       = 1
    static let P_SYNC_START  = 2
    static let P_SYNC_END    = 3
    static let P_ROUTE_START = 4
    static let P_ROUTE_END   = 5
    static let P_IOERROR     = 6
    static let P_DONE        = 7
}

class JourneySyncProgressEventData {
    var action : Int = JourneySyncProgressEvent.P_BEGIN
    var nRoutes : Int = 0
    var iRoute : Int = 0
    var beginTime : TimeValue64 = 0
    var syncStartTime : TimeValue64 = 0
    var syncEndTime : TimeValue64 = 0
    var routeTimes : [[String:TimeValue64]] = [[String:TimeValue64]]()
    var endTime : TimeValue64 = 0
    var ioError : HttpStatusLine?
    var isForced : Bool = false
    
    init() {
        
    }
    
    func dup() -> JourneySyncProgressEventData {
        var j = JourneySyncProgressEventData()
        j.action = action
        j.nRoutes = nRoutes
        j.iRoute = iRoute
        j.beginTime = beginTime
        j.syncStartTime = syncStartTime
        j.syncEndTime = syncEndTime
        j.routeTimes = [[String:TimeValue64]](routeTimes)
        j.endTime = endTime
        j.ioError = ioError
        j.isForced = isForced
        return j
    }
}

class JourneySyncProgressListener : ProgressListener, OnIOErrorListener {
    var api : BuspassApi
    var eventData = JourneySyncProgressEventData()
    
    init(api : BuspassApi) {
        self.api = api
    }
    
    func onBegin(isForced : Bool) {
        eventData = JourneySyncProgressEventData()
        eventData.isForced = isForced
        eventData.beginTime = UtilsTime.current()
        api.uiEvents.postEvent("JourneySyncProgress", data: eventData.dup())
    }
    
    func onSyncStart() {
        eventData.action = JourneySyncProgressEvent.P_SYNC_START
        eventData.syncStartTime = UtilsTime.current()
        api.uiEvents.postEvent("JourneySyncProgress", data: eventData.dup())
    }
    
    func onSyncEnd(nRoutes: Int) {
        eventData.action = JourneySyncProgressEvent.P_SYNC_END
        eventData.nRoutes = nRoutes
        eventData.syncEndTime = UtilsTime.current()
        api.uiEvents.postEvent("JourneySyncProgress", data: eventData.dup())
    }
    
    func onRouteStart(iRoute: Int) {
        eventData.action = JourneySyncProgressEvent.P_ROUTE_START
        eventData.iRoute = iRoute
        eventData.routeTimes.insert(["start" : UtilsTime.current()], atIndex: iRoute)
        api.uiEvents.postEvent("JourneySyncProgress", data: eventData.dup())
    }
    
    func onRouteEnd(iRoute: Int) {
        eventData.action = JourneySyncProgressEvent.P_ROUTE_END
        eventData.iRoute = iRoute
        eventData.routeTimes[iRoute]["end"] = UtilsTime.current()
        api.uiEvents.postEvent("JourneySyncProgress", data: eventData.dup())
    }
    
    func onIOError(journeyBasket: JourneyBasket, statusLine: HttpStatusLine) {
        eventData.action = JourneySyncProgressEvent.P_IOERROR
        eventData.ioError = statusLine
        api.uiEvents.postEvent("JourneySyncProgress", data: eventData.dup())
    }
    
    func onDone() {
        eventData.action = JourneySyncProgressEvent.P_DONE
        eventData.endTime = UtilsTime.current()
        api.uiEvents.postEvent("JourneySyncProgress", data: eventData.dup())
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}