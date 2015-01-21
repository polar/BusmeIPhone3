//
//  JourneySyncProgressEvent.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public struct JourneySyncProgressEvent {
    public static let P_BEGIN       = 1
    public static let P_SYNC_START  = 2
    public static let P_SYNC_END    = 3
    public static let P_ROUTE_START = 4
    public static let P_ROUTE_END   = 5
    public static let P_IOERROR     = 6
    public static let P_DONE        = 7
}

public class JourneySyncProgressEventData {
    public var action : Int = JourneySyncProgressEvent.P_BEGIN
    public var nRoutes : Int = 0
    public var iRoute : Int = 0
    public var beginTime : TimeValue64 = 0
    public var syncStartTime : TimeValue64 = 0
    public var syncEndTime : TimeValue64 = 0
    public var routeTimes : [[String:TimeValue64]] = [[String:TimeValue64]]()
    public var endTime : TimeValue64 = 0
    public var ioError : HttpStatusLine?
    public var isForced : Bool = false
    
    public init() {
        
    }
    
    public func dup() -> JourneySyncProgressEventData {
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

public class JourneySyncProgressListener : ProgressListener, OnIOErrorListener {
    public var api : BuspassApi
    public var eventData = JourneySyncProgressEventData()
    
    public init(api : BuspassApi) {
        self.api = api
    }
    
    public func onBegin(isForced : Bool) {
        eventData = JourneySyncProgressEventData()
        eventData.isForced = isForced
        eventData.beginTime = UtilsTime.current()
        api.uiEvents.postEvent("JourneySyncProgress", data: eventData.dup())
    }
    
    public func onSyncStart() {
        eventData.action = JourneySyncProgressEvent.P_SYNC_START
        eventData.syncStartTime = UtilsTime.current()
        api.uiEvents.postEvent("JourneySyncProgress", data: eventData.dup())
    }
    
    public func onSyncEnd(nRoutes: Int) {
        eventData.action = JourneySyncProgressEvent.P_SYNC_END
        eventData.nRoutes = nRoutes
        eventData.syncEndTime = UtilsTime.current()
        api.uiEvents.postEvent("JourneySyncProgress", data: eventData.dup())
    }
    
    public func onRouteStart(iRoute: Int) {
        eventData.action = JourneySyncProgressEvent.P_ROUTE_START
        eventData.iRoute = iRoute
        eventData.routeTimes.insert(["start" : UtilsTime.current()], atIndex: iRoute)
        api.uiEvents.postEvent("JourneySyncProgress", data: eventData.dup())
    }
    
    public func onRouteEnd(iRoute: Int) {
        eventData.action = JourneySyncProgressEvent.P_ROUTE_END
        eventData.iRoute = iRoute
        eventData.routeTimes[iRoute]["end"] = UtilsTime.current()
        api.uiEvents.postEvent("JourneySyncProgress", data: eventData.dup())
    }
    
    public func onIOError(journeyBasket: JourneyBasket, statusLine: HttpStatusLine) {
        eventData.action = JourneySyncProgressEvent.P_IOERROR
        eventData.ioError = statusLine
        api.uiEvents.postEvent("JourneySyncProgress", data: eventData.dup())
    }
    
    public func onDone() {
        eventData.action = JourneySyncProgressEvent.P_DONE
        eventData.endTime = UtilsTime.current()
        api.uiEvents.postEvent("JourneySyncProgress", data: eventData.dup())
    }
}