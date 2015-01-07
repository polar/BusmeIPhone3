//
//  Route.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/6/15.
//  Copyright (c) as? String as? String 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

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
    public var version : TimeValue64?
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
    public var patternids : [String]?
    public var lastKnownLocation : GeoPoint?
    public var lastKnownTime : String?
    public var lastKnownTimediff : Double?
    public var lastKnownDistance : Double?
    public var lastKnownDirection : Double?
    public var onRoute : Bool = false
    public var timeZone : String?
    public var reported : Bool = false
    public var reporting : Bool = false
    
    public var journeyStore : JourneyStore?
    
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
        self.patternids = coder.decodeObjectForKey("patternids") as? [String]
//        self.lastKnownLocation = coder.decodeObjectForKey("lastKnownLocation") as? GeoPoint
//        self.lastKnownTime = coder.decodeObjectForKey("lastKnownTime") as? String
//        self.lastKnownTimediff = coder.decodeObjectForKey("lastKnownTimediff") as? String
//        self.lastKnownDistance = coder.decodeDoubleForKey("lastKnownDistance")
//        self.lastKnownDirection = coder.decodeDoubleForKey("lastKnownDirection")
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
        if (version != nil) { coder.encodeInt64(version!, forKey: "version") }
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
//        if (lastKnownLocation != nil) { coder.encodeObject(lastKnownLocation!, forKey: "lastKnownLocation") }
//        if (lastKnownTime != nil) { coder.encodeObject(lastKnownTime!, forKey: "lastKnownTime") }
//        if (lastKnownTimediff != nil) { coder.encodeObject(lastKnownTimediff!, forKey: "lastKnownTimediff") }
//        if (lastKnownDistance != nil) { coder.encodeDouble(lastKnownDistance!, forKey: "lastKnownDistance") }
//        if (lastKnownDirection != nil) { coder.encodeDouble(lastKnownDirection!, forKey: "lastKnownDirection") }
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
    }
    public func getStartTime() -> TimeValue64 {
        if (schedStartTime != nil) {
            return schedStartTime!
        } else {
            return UtilsTime.current()
        }
    }
    public func getEndTime() -> TimeValue64 {
        return getStartTime() + Int64(duration! * 60)
    }
    public func isFinished() -> Bool {
        let loc = lastKnownLocation
        if (loc != nil) {
            let distance = lastKnownDistance!
            let path_distance = getJourneyPattern(patternid!)!.distance!
            let dist_from_last = GeoCalc.getGeoDistance(loc!, c2: getJourneyPattern(patternid!)!.getEndPoint()!)
            return path_distance - distance < 10 && dist_from_last < 3 // feet
        } else {
            return false
        }
    }
    public func getJourneyPattern(id : String) -> JourneyPattern? {
        return journeyStore!.getPattern(id)
    }
    
    private var _journeyPatterns : [JourneyPattern] = [JourneyPattern]()
    
    public func getJourneyPatterns() -> [JourneyPattern] {
        if self._journeyPatterns.count == 0 {
            var pids : [String] = patternids != nil ? patternids! : [String]()
            pids += patternid != nil ? [patternid!] : [String]()
            var pats = [String : JourneyPattern]()
            for pid in pids {
                if pats[pid] == nil {
                    let pat = getJourneyPattern(pid)
                    if pat != nil {
                        pats[pid] = pat
                    }
                }
            }
            if (pids.count == pats.count) {
                self._journeyPatterns = pats.values.array
            }
        }
        return _journeyPatterns
    }
    
    private var _paths : [[CLLocationCoordinate2D]] = [[CLLocationCoordinate2D]]()
    
    public func getPaths() -> [[CLLocationCoordinate2D]] {
        if (_paths.count == 0) {
            var paths = [[CLLocationCoordinate2D]]()
            for pat in getJourneyPatterns() {
                if pat.isReady() {
                    paths.append(pat.path!)
                }
            }
            self._paths = paths
        }
        return _paths
    }
    
    private var _projectedPaths : [[MKMapPoint]] = [[MKMapPoint]]()
    
    public func getPorjectedPaths() -> [[MKMapPoint]] {
        if (_projectedPaths.count == 0) {
            var paths = [[MKMapPoint]]()
            for pat in getJourneyPatterns() {
                if pat.isReady() {
                    paths.append(pat.getProjectedPath())
                }
            }
            _projectedPaths = paths
        }
        return _projectedPaths
    }
    
    public func getStartingPoint() -> GeoPoint? {
        if isJourney() {
            getJourneyPatterns()
            let path = getPaths().first
            if path != nil {
                return path!.first
            }
        }
        return nil
    }
    
    public func isStartingJourney() -> Bool {
        if (busAPI != nil) {
            return isStartingJourney(busAPI!.activeStartDisplayThreshold, time: UtilsTime.current())
        } else {
            return false
        }
    }
    public func isStartingJourney(threshold : Double) -> Bool {
        if (busAPI != nil) {
            return isStartingJourney(threshold, time: UtilsTime.current())
        } else {
            return false
        }
    }
    public func isStartingJourney(threshold : Double, time : TimeValue64) -> Bool {
        if (isJourney() && busAPI != nil) {
            let startMeasure = getStartingMeasure(threshold, time: time)
            return 0.0 < startMeasure && startMeasure < 1.0
        }
        return false
    }
    
    public func getStartingMeasure() -> Double {
        if (busAPI != nil) {
            return getStartingMeasure(busAPI!.activeStartDisplayThreshold, time: UtilsTime.current())
        } else {
            return 1.0
        }
    }
    public func getStartingMeasure(threshold : Double) -> Double {
        if (busAPI != nil) {
            return getStartingMeasure(threshold, time: UtilsTime.current())
        } else {
            return 1.0
        }
    }
    public func getStartingMeasure(threshold : Double, time: TimeValue64) -> Double {
        let startTime = getStartTime()
        let timediff = Double(time - startTime) * 1000.0 // time in seconds, threshold in millis
        var ret = 1.0
        var diff = 0.0
        var distance = -1.0
        let loc = lastKnownLocation
        if loc != nil {
            let start = getStartingPoint()!
            distance = GeoCalc.getGeoDistance(start, c2: loc!)
            if (0 <= distance && distance < 15) { // feet
                if (0 <= timediff && timediff <= threshold) {
                    diff = threshold - timediff
                    ret = (diff*diff)/(threshold*threshold)
                } else {
                    ret = -1.0
                }
            } else {
                ret = 1.1
            }
        } else {
            if (0 <= timediff && timediff <= threshold) {
                diff = threshold - timediff
                ret = (diff*diff)/(threshold*threshold)
            } else {
                ret = -1.0
            }
        }
        return ret
    }
    
    public func loadParsedXML(tag : Tag) -> Route? {
        self.type = tag.attributes["type"]
        self.id = tag.attributes["id"]
        self.name = tag.attributes["name"]
        if (tag.attributes["distance"] != nil) {
            self.distance = (tag.attributes["distance"]! as NSString).doubleValue
        }
        if (tag.attributes["dir"] != nil) {
            self.direction = (tag.attributes["dir"]! as NSString).doubleValue
        }
        self.code = tag.attributes["routeCode"]
        if (tag.attributes["version"] != nil) {
            self.version = Int64((tag.attributes["version"]! as NSString).integerValue)
        }
        self.routeid = tag.attributes["routeid"]
        self.patternid = tag.attributes["patternid"]
        self.vid = tag.attributes["vid"]
        if (tag.attributes["duration"] != nil) {
            self.duration = (tag.attributes["duration"]! as NSString).doubleValue
        }
        if (tag.attributes["sort"] != nil) {
            self.sort = (tag.attributes["sort"]! as NSString).doubleValue
        }
        
        if (tag.attributes["locationRefreshRate"] != nil) {
            self.locationRefreshRate = (tag.attributes["locationRefreshRate"]! as NSString).doubleValue
        }

        self.timeZone = tag.attributes["time_zone"]
        if (tag.attributes["schedStartTime"] != nil) {
            self.schedStartTime = Int64((tag.attributes["schedStartTime"]! as NSString).integerValue)
        }
        if (tag.attributes["nw_lon"] != nil) {
            self.nw_lon = (tag.attributes["nw_lon"]! as NSString).doubleValue
        }
        
        if (tag.attributes["nw_lat"] != nil) {
            self.nw_lat = (tag.attributes["nw_lat"]! as NSString).doubleValue
        }
        
        if (tag.attributes["se_lon"] != nil) {
            self.se_lon = (tag.attributes["se_lon"]! as NSString).doubleValue
        }
        
        if (tag.attributes["se_lat"] != nil) {
            self.se_lat = (tag.attributes["se_lat"]! as NSString).doubleValue
        }

        self.timeless = tag.attributes["timeless"] != nil ? tag.attributes["timeless"] == "true" : false
        
        if (tag.attributes["startOffset"] != nil) {
            self.startOffset = (tag.attributes["startOffset"]! as NSString).doubleValue
        }
        
        if (tag.attributes["patternids"] != nil) {
            self.patternids = tag.attributes["patternids"]!.componentsSeparatedByString(",")
        }
        if isValid() {
            return self
        } else {
            return nil
        }
    }
    
    public func isValid() -> Bool {
        var valid = type != nil && id != nil && name != nil && code != nil && version != nil && sort != nil && nw_lon != nil && nw_lat != nil && se_lon != nil && se_lat != nil
        if valid {
            if (type! == "route") {
                valid &= routeid != nil && distance != nil && direction != nil && patternid != nil && duration != nil && startOffset != nil
            } else if (type! == "journey") {
                valid &= patternids != nil && !patternids!.isEmpty
            }
        }
        return valid
    }

    public func pushCurrentLocation(loc : JourneyLocation) -> (GeoPoint, GeoPoint?) {
        let gp = GeoPointImpl(lat: loc.lat, lon: loc.lon)
        let lastLocation = lastKnownLocation
        self.lastKnownLocation = gp
        self.lastKnownTimediff = loc.timediff
        self.lastKnownDirection = loc.dir
        self.lastKnownDistance = loc.distance
        self.lastKnownTime = UtilsTime.stringForTime(loc.reported_time)
        self.onRoute = loc.onroute
        self.reported = loc.reported
        return (lastKnownLocation!, lastLocation)
    }
}