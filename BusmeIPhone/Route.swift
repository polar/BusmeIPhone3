//
//  Route.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/6/15.
//  Copyright (c) as? String as? String 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation

public class Route : Storage {
    public var busAPI : BuspassApi?
    public var name : String?
    public var type : String?
    public var id : String?
    public var code : String?
    public var direction : Double?
    public var distance : Double?
    public var vid : String?
    public var workingVid : String?
    public var timeless : Bool = false
    public var sort : Double?
    public var version : TimeValue64 = -1
    public var nw_lon : Double?
    public var nw_lat : Double?
    public var se_lon : Double?
    public var se_lat : Double?
    public var locationRefreshRate : Double = 10.0
    public var startOffset : Double?
    public var duration : Double?
    public var startTime : Double?
    public var endTime : Double?
    public var schedStartTime : TimeValue64?
    public var actualStartTime : TimeValue64?
    public var routeid : String?
    public var patternid : String?
    public var patternids : String?
    public var lastKnownLocation : String?
    public var lastKnownTime : String?
    public var lastKnownTimediff : String?
    public var lastKnownDistance : Double?
    public var lastKnownDirection : Double?
    public var onRoute : Bool = false
    public var timeZone : String?
    public var reported : Bool = false
    public var reporting : Bool = false
    
    public func initWithCoder(coder : NSCoder) -> Route {
        self.name = coder.decodeObjectForKey("name") as? String
        self.type = coder.decodeObjectForKey("type") as? String
        self.id = coder.decodeObjectForKey("id") as? String
        self.code = coder.decodeObjectForKey("code") as? String
        self.direction = coder.decodeDoubleForKey("direction")
        self.distance = coder.decodeDoubleForKey("distance")
        self.vid = coder.decodeObjectForKey("vid") as? String
        self.workingVid = coder.decodeObjectForKey("workingVid") as? String
        self.timeless = coder.decodeBoolForKey("timeless")
        self.sort = coder.decodeDoubleForKey("sort")
        self.version = coder.decodeInt64ForKey("version")
        self.nw_lon = coder.decodeDoubleForKey("nw_lon")
        self.nw_lat = coder.decodeDoubleForKey("nw_lat")
        self.se_lon = coder.decodeDoubleForKey("se_lon")
        self.se_lat = coder.decodeDoubleForKey("se_lat")
        self.locationRefreshRate = coder.decodeDoubleForKey("locationRefreshRate")
        self.startOffset = coder.decodeDoubleForKey("startOffset")
        self.duration = coder.decodeDoubleForKey("duration")
        self.startTime = coder.decodeDoubleForKey("startTime")
        self.endTime = coder.decodeDoubleForKey("endTime")
        self.schedStartTime = coder.decodeInt64ForKey("schedStartTime")
        self.actualStartTime = coder.decodeInt64ForKey("actualStartTime")
        self.routeid = coder.decodeObjectForKey("routeid") as? String
        self.patternid = coder.decodeObjectForKey("patternid") as? String
        self.patternids = coder.decodeObjectForKey("patternids") as? String
        self.lastKnownLocation = coder.decodeObjectForKey("lastKnownLocation") as? String
        self.lastKnownTime = coder.decodeObjectForKey("lastKnownTime") as? String
        self.lastKnownTimediff = coder.decodeObjectForKey("lastKnownTimediff") as? String
        self.lastKnownDistance = coder.decodeDoubleForKey("lastKnownDistance")
        self.lastKnownDirection = coder.decodeDoubleForKey("lastKnownDirection")
        self.onRoute = coder.decodeBoolForKey("onRoute")
        self.timeZone = coder.decodeObjectForKey("timeZone") as? String
        self.reported = coder.decodeBoolForKey("reported")
        return self
    }
    
    public func encodeWithCoder(coder : NSCoder) -> Route {
        if (name != nil) { coder.encodeObject(name!, forKey: "name") }
        if (type != nil) { coder.encodeObject(type!, forKey: "type") }
        if (id != nil) { coder.encodeObject(id!, forKey: "id") }
        if (code != nil) { coder.encodeObject(code!, forKey: "code") }
        if (direction != nil) { coder.encodeDouble(direction!, forKey: "direction") }
        if (distance != nil) { coder.encodeDouble(distance!, forKey: "distance") }
        if (vid != nil) { coder.encodeObject(vid!, forKey: "vid") }
        if (workingVid != nil) { coder.encodeObject(workingVid!, forKey: "workingVid") }
        coder.encodeBool(timeless, forKey: "timeless")
        if (sort != nil) { coder.encodeDouble(sort!, forKey: "sort") }
        coder.encodeInt64(version, forKey: "version")
        if (nw_lon != nil) { coder.encodeDouble(nw_lon!, forKey: "nw_lon") }
        if (nw_lat != nil) { coder.encodeDouble(nw_lat!, forKey: "nw_lat") }
        if (se_lon != nil) { coder.encodeDouble(se_lon!, forKey: "se_lon") }
        if (se_lat != nil) { coder.encodeDouble(se_lat!, forKey: "se_lat") }
        coder.encodeDouble(locationRefreshRate, forKey: "locationRefreshRate")
        if (startOffset != nil) { coder.encodeDouble(startOffset!, forKey: "startOffset") }
        if (duration != nil) { coder.encodeDouble(duration!, forKey: "duration") }
        if (startTime != nil) { coder.encodeDouble(startTime!, forKey: "startTime") }
        if (endTime != nil) { coder.encodeDouble(endTime!, forKey: "endTime") }
        if (schedStartTime != nil) { coder.encodeInt64(schedStartTime!, forKey: "schedStartTime") }
        if (actualStartTime != nil) { coder.encodeInt64(actualStartTime!, forKey: "actualStartTime") }
        if (routeid != nil) { coder.encodeObject(routeid!, forKey: "routeid") }
        if (patternid != nil) { coder.encodeObject(patternid!, forKey: "patternid") }
        if (patternids != nil) { coder.encodeObject(patternids!, forKey: "patternids") }
        if (lastKnownLocation != nil) { coder.encodeObject(lastKnownLocation!, forKey: "lastKnownLocation") }
        if (lastKnownTime != nil) { coder.encodeObject(lastKnownTime!, forKey: "lastKnownTime") }
        if (lastKnownTimediff != nil) { coder.encodeObject(lastKnownTimediff!, forKey: "lastKnownTimediff") }
        if (lastKnownDistance != nil) { coder.encodeDouble(lastKnownDistance!, forKey: "lastKnownDistance") }
        if (lastKnownDirection != nil) { coder.encodeDouble(lastKnownDirection!, forKey: "lastKnownDirection") }
        coder.encodeBool(onRoute, forKey: "onRoute")
        if (timeZone != nil) { coder.encodeObject(timeZone!, forKey: "timeZone") }
        coder.encodeBool(reported, forKey: "reported")
        return self
    }
    
    public override func preSerialize(api : ApiBase, time : TimeValue64) {
        
    }
    
    public override func postSerialize(api : ApiBase, time : TimeValue64) {
        self.busAPI = api as? BuspassApi
    }
    
    public func isJourney() -> Bool {
        return "journey" == type!
    }
    
    public func isRouteDefinition() -> Bool {
        return "route" == type!
    }
    
    public func isActiveJourney() -> Bool {
        return isJourney() && lastKnownLocation != nil
    }
    public func isReporting() -> Bool {
        return reporting
    }
    public func isReported() -> Bool {
        return reported
    }
    public func isTimeless() -> Bool {
        return timeless
    }}