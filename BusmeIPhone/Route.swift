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

class Route : Storage {
    weak var busAPI : BuspassApi?
    weak var journeyStore : JourneyStore?
    
    var name : String?
    var type : String?
    var id : String?
    var code : String?
    var direction : String?
    var distance : Double?
    var vid : String?
    var workingVid : String?
    var timeless : Bool = false
    var sort : Double?
    var version : TimeValue64?
    var nw_lon : Double?
    var nw_lat : Double?
    var se_lon : Double?
    var se_lat : Double?
    var locationRefreshRate : Double = 10.0
    var startOffset : Double?
    var duration : Double?
    var startTime : Double?
    var endTime : Double?
    var schedStartTime : TimeValue64?
    var actualStartTime : TimeValue64?
    var routeid : String?
    var patternid : String?
    var patternids : [String]?
    var lastKnownLocation : GeoPoint?
    var lastKnownTime : String?
    var lastKnownTimediff : Double?
    var lastKnownDistance : Double?
    var lastKnownDirection : Double?
    var lastLocationUpdate : TimeValue64?
    var onRoute : Bool = false
    var timeZone : String?
    var reported : Bool = false
    var reporting : Bool = false
    var distanceTolerance : Double = 60.0
    
    init(tag : Tag) {
        super.init()
        loadParsedXML(tag)
    }
    
    
    override init(coder : NSCoder) {
        super.init()
        self.name = coder.decodeObjectForKey("name") as? String
        self.type = coder.decodeObjectForKey("type") as? String
        self.id = coder.decodeObjectForKey("id") as? String
        self.code = coder.decodeObjectForKey("code") as? String
        self.direction = coder.decodeObjectForKey("direction") as? String
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
        //self.schedStartTime = coder.decodeInt64ForKey("schedStartTime")
        //self.actualStartTime = coder.decodeInt64ForKey("actualStartTime")
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
        // Added, should be removed and just set up straight after progress.
        let dt = coder.decodeDoubleForKey("distanceTolerance")
        if dt != 0.0 { self.distanceTolerance = dt }
    }
    
    func encodeWithCoder(coder : NSCoder) {
        if (name != nil) { coder.encodeObject(name!, forKey: "name") }
        if (type != nil) { coder.encodeObject(type!, forKey: "type") }
        if (id != nil) { coder.encodeObject(id!, forKey: "id") }
        if (code != nil) { coder.encodeObject(code!, forKey: "code") }
        if (direction != nil) { coder.encodeObject(direction!, forKey: "direction") }
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
        //if (schedStartTime != nil) { coder.encodeInt64(schedStartTime!, forKey: "schedStartTime") }
        //if (actualStartTime != nil) { coder.encodeInt64(actualStartTime!, forKey: "actualStartTime") }
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
        coder.encodeDouble(distanceTolerance, forKey: "distanceTolerance")
    }
    
    override func preSerialize(api : ApiBase, time : TimeValue64) {
        
    }
    
    override func postSerialize(api : ApiBase, time : TimeValue64) {
        self.busAPI = api as? BuspassApi
    }
    
    func isJourney() -> Bool {
        return "journey" == type!
    }
    
    func isRouteDefinition() -> Bool {
        return "route" == type!
    }
    
    // Set by JourneyBasket.
    
    private var activeJourney : Bool = false
    func setActive(active: Bool) {
        activeJourney = active
    }
    func isActiveJourney() -> Bool {
        // TODO This might be a litle different. The fact that it shows up in the sync, should
        // mean it's active.
        return isJourney() && activeJourney // lastKnownLocation != nil
    }
    func isReporting() -> Bool {
        return reporting
    }
    func isReported() -> Bool {
        return reported
    }
    func isTimeless() -> Bool {
        return timeless
    }
    func getStartTime() -> TimeValue64 {
        if (schedStartTime != nil) {
            return schedStartTime!
        } else {
            return UtilsTime.current()
        }
    }
    func getEndTime() -> TimeValue64 {
        return getStartTime() + Int64(duration! * 60 * 1000)
    }
    func isFinished() -> Bool {
        let loc = lastKnownLocation
        if (loc != nil) {
            let distance = lastKnownDistance!
            if patternid != nil {
                let pattern = getJourneyPattern(patternid!)
                if (pattern != nil && pattern!.isReady()) {
                    let path_distance = pattern!.distance!
                    let dist_from_last = GeoCalc.getGeoDistance(loc!, c2: pattern!.getEndPoint()!)
                    return path_distance - distance < 10 && dist_from_last < 3 // feet
                } else {
                    return false
                }
            } else {
                return false
            }
        } else {
            return false
        }
    }
    func getJourneyPattern(id : String) -> JourneyPattern? {
        return journeyStore!.getPattern(id)
    }
    
    private var _journeyPatterns : [JourneyPattern] = [JourneyPattern]()
    
    func getJourneyPatterns() -> [JourneyPattern] {

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
    
    private var _paths : [[GeoPoint]] = [[GeoPoint]]()
    
    func getPaths() -> [[GeoPoint]] {

        if (_paths.count == 0) {
            var paths = [[GeoPoint]]()
            for pat in getJourneyPatterns() {
                if pat.isReady() {
                    paths.append(pat.path!)
                }
            }
            self._paths = paths
        }
        return _paths
    }
    
    private var _projectedPaths : [[Point]] = [[Point]]()
    
    func getProjectedPaths() -> [[Point]] {
        
        if (_projectedPaths.count == 0) {
            var paths = [[Point]]()
            for pat in getJourneyPatterns() {
                if pat.isReady() {
                    paths.append(pat.getProjectedPath())
                }
            }
            _projectedPaths = paths
        }
        return _projectedPaths
    }
    
    func getStartingPoint() -> GeoPoint? {

        if isJourney() {
            getJourneyPatterns()
            let path = getPaths().first
            if path != nil {
                return path!.first
            }
        }
        return nil
    }
    
    func isStartingJourney() -> Bool {

        if (busAPI != nil) {
            return isStartingJourney(busAPI!.activeStartDisplayThreshold, time: UtilsTime.current())
        } else {
            return false
        }
    }
    func isStartingJourney(threshold : Double) -> Bool {

        if (busAPI != nil) {
            return isStartingJourney(threshold, time: UtilsTime.current())
        } else {
            return false
        }
    }
    func isStartingJourney(threshold : Double, time : TimeValue64) -> Bool {
        if (isJourney() && busAPI != nil) {
            let startMeasure = getStartingMeasure(threshold, time: time)
            return 0.0 < startMeasure && startMeasure < 1.0
        }
        return false
    }
    
    func isNotYetStartingJourney() -> Bool {
        if (isJourney() && busAPI != nil) {
            let startMeasure = getStartingMeasure(busAPI!.activeStartDisplayThreshold, time: UtilsTime.current())
            return startMeasure < 0.0
        }
        return false
    }
    
    func getStartingMeasure() -> Double {
        if (busAPI != nil) {
            return getStartingMeasure(busAPI!.activeStartDisplayThreshold, time: UtilsTime.current())
        } else {
            return 1.0
        }
    }
    func getStartingMeasure(threshold : Double) -> Double {
        if (busAPI != nil) {
            return getStartingMeasure(threshold, time: UtilsTime.current())
        } else {
            return 1.0
        }
    }
    func getStartingMeasure(threshold : Double, time: TimeValue64) -> Double {
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
    
    func isNearRoute(point : GeoPoint, buffer : Double) -> Bool {
        var isNearRoute = false
        for jp in getJourneyPatterns() {
            let path = jp.path!
            isNearRoute |= GeoPathUtils.isOnPath(path, buffer: buffer, c3: point)
            if isNearRoute {
                break
            }
        }
        return isNearRoute
    }
    
    func whereOnPaths(point : GeoPoint, buffer : Double) -> [DGeoPoint] {
        var result = [DGeoPoint]()
        for jp in getJourneyPatterns() {
            let path = jp.path!
            let possibles = GeoPathUtils.whereOnPath(path, buffer: buffer, point: point)
            result += possibles
        }
        return result
    }
    
    private var _zoomcenter : CLLocationCoordinate2D?
    func getZoomCenter() -> GeoPoint {
        if (_zoomcenter == nil) {
            let lat = se_lat! + (nw_lat! - se_lat!)/2.0
            let dx = nw_lon! - se_lon!
            var lon = se_lon! + dx/2
            lon = lon < -180 ? lon+360 : lon
            lon = lon > 180 ? lon-360 : lon
            self._zoomcenter = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return _zoomcenter!
    }
    
    func updateStartTimes(nameid : NameId) {
        self.actualStartTime = nameid.time_start
        self.schedStartTime = nameid.sched_time_start
    }
    
    func loadParsedXML(tag : Tag) -> Route? {
        self.type = tag.attributes["type"]
        self.id = tag.attributes["id"]
        self.name = tag.attributes["name"]
        self.code = tag.attributes["routeCode"]
        
        let distance = tag.attributes["distance"] as NSString?
        if (distance != nil) {
            self.distance = distance!.doubleValue
        }
        
        let dir = tag.attributes["dir"] as NSString?
        if (dir != nil) {
            self.direction = dir!
        }
        
        let version = tag.attributes["version"] as NSString?
        if (version != nil) {
            self.version = Int64(version!.integerValue)
        }
        
        self.routeid = tag.attributes["routeid"]
        self.patternid = tag.attributes["patternid"]
        self.vid = tag.attributes["vid"]
        
        let duration = tag.attributes["duration"] as NSString?
        if (duration != nil) {
            self.duration = duration!.doubleValue
        }
        
        let sort = tag.attributes["sort"] as NSString?
        if (sort != nil) {
            self.sort = sort!.doubleValue
        }
        
        let locationRefreshRate = tag.attributes["locationRefreshRate"] as NSString?
        if (locationRefreshRate != nil) {
            self.locationRefreshRate = locationRefreshRate!.doubleValue
        }
        
        self.timeZone = tag.attributes["time_zone"]
        
        let schedStartTime = tag.attributes["schedStartTime"] as NSString?
        if (schedStartTime != nil) {
            self.schedStartTime = Int64(schedStartTime!.integerValue)
        }
        
        let nw_lon = tag.attributes["nw_lon"] as NSString?
        if (nw_lon != nil) {
            self.nw_lon = nw_lon!.doubleValue
        }
        
        let nw_lat = tag.attributes["nw_lat"] as NSString?
        if (nw_lat != nil) {
            self.nw_lat = nw_lat!.doubleValue
        }
        
        let se_lon = tag.attributes["se_lon"] as NSString?
        if (se_lon != nil) {
            self.se_lon = se_lon!.doubleValue
        }
        
        let se_lat = tag.attributes["se_lat"] as NSString?
        if (se_lat != nil) {
            self.se_lat = se_lat!.doubleValue
        }
        
        let timeless = tag.attributes["timeless"]
        self.timeless = timeless != nil ? timeless! == "true" : false
        
        let startOffset = tag.attributes["startOffset"] as NSString?
        if (startOffset != nil) {
            self.startOffset = startOffset!.doubleValue
        }
        
        let patternids = tag.attributes["patternids"]
        if (patternids != nil) {
            self.patternids = patternids!.componentsSeparatedByString(",")
        }
        
        let disT = tag.attributes["distanceTolerance"] as NSString?
        if (disT != nil) {
            self.distanceTolerance = disT!.doubleValue
        }
        
        if isValid() {
            return self
        } else {
            return nil
        }
    }
    
    func isValid() -> Bool {
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

    func pushCurrentLocation(loc : JourneyLocation) -> (GeoPoint, GeoPoint?) {
//        if isReporting() {
//            // We are reporting on this, so the lastKnownLocation and stuff
//            // should already be set.
//            return (lastKnownLocation!, lastKnownLocation!)
//        }
        let gp = GeoPointImpl(lat: loc.lat, lon: loc.lon)
        let lastLocation = lastKnownLocation
        self.lastKnownLocation = gp
        self.lastKnownTimediff = loc.timediff
        self.lastKnownDirection = loc.dir
        self.lastKnownDistance = loc.distance
        self.lastKnownTime = UtilsTime.stringForTime(loc.reported_time)
        self.lastLocationUpdate = UtilsTime.current()
        self.onRoute = loc.onroute
        self.reported = loc.reported
        if lastLocation != nil {
            let distance = GeoCalc.getGeoDistance(lastLocation!, c2: lastKnownLocation!)
            if BLog.DEBUG {
                BLog.logger.debug("\(name): pushLocation(\(loc)\(gp.getLatitude()), \(gp.getLongitude()) distance between locs \(distance) \(lastLocation!.getLatitude()), \(lastLocation!.getLongitude())")
                if distance > 1000 {
                    BLog.logger.debug("HERE!!!")
                }
            }
        }
        return (lastKnownLocation!, lastLocation)
    }
    
    func toString() -> String {
        var s = ""
        if isRouteDefinition() {
            s = "Route(\(code), \(name), paths=\(getPaths().count), id=\(id)"
        }
        if isJourney() {
            s = "Journey(\(code) \(name) id=\(id), patid=\(patternid),"
            if isActiveJourney() {
                s += ", ActiveJourney"
            }
            if isStartingJourney() {
                s += "Starting, "
            }
            if isNotYetStartingJourney() {
                s += ", NotYetStartingJourney"
            }
            if isFinished() {
                s += ", Finished"
            }
            if isTimeless() {
                s += ", Timeless"
            }
            s += "vid=\(vid) wvid=\(workingVid) st=\(getStartTime()) et=\(getEndTime())"
        }
        return s
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC Route \(self.name)") }
    }
}