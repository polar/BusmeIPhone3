//
//  GeoPathUtils.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation
import CoreGraphics
import MapKit

protocol GeoPoint : Point {
    func getLatitude() -> Double
    func getLongitude() -> Double
}


protocol GeoPointMutable : GeoPoint {
    func setLatitude(lat : Double)
    func setLongitude(lon :Double)
    func set(lat : Double, lon : Double) -> GeoPointMutable
}

class BoundingBox : NSObject {
    var eastE6 : Int = 0
    var westE6 : Int = 0
    var northE6 : Int = 0
    var southE6 : Int = 0
    
    
    init(array: [String]) { // E, S, W, N
        super.init()
        setEast((array[2] as NSString).doubleValue)
        setSouth((array[3] as NSString).doubleValue)
        setWest((array[0] as NSString).doubleValue)
        setNorth((array[1] as NSString).doubleValue)
    }

    init(north: Double, east: Double, west: Double, south : Double) {
        super.init()

        setNorth(north)
        setEast(east)
        setWest(west)
        setSouth(south)
    }
    
    init(northE6: Int, eastE6: Int, westE6: Int, southE6: Int) {
        super.init()

        setNorthE6(northE6)
        setEastE6(eastE6)
        setWestE6(westE6)
        setSouthE6(southE6)
    }
    
    func toGeoRect() -> GeoRect {
        return GeoRect(left: west(), top: north(), right: east(), bottom: south())
    }
    
    init( coder : NSCoder) {
        super.init()

        self.eastE6 = Int(coder.decodeIntForKey("eastE6"))
        self.westE6 = Int(coder.decodeIntForKey("westE6"))
        self.northE6 = Int(coder.decodeIntForKey("northE6"))
        self.southE6 = Int(coder.decodeIntForKey("southE6"))
    }
    
    func encodeWithCoder( coder : NSCoder) {
        coder.encodeInt(Int32(eastE6), forKey: "eastE6")
        coder.encodeInt(Int32(westE6), forKey: "westE6")
        coder.encodeInt(Int32(southE6), forKey: "southE6")
        coder.encodeInt(Int32(northE6), forKey: "northE6")
    }
    
    func east() -> Double {
        return Double(eastE6) / 1E6
    }
    
    func west() -> Double {
        return Double(westE6) / 1E6
    }
    
    func north() -> Double {
        return Double(northE6) / 1E6
    }
    
    func south() -> Double {
        return Double(southE6) / 1E6
    }
    
    func setEast(x :Double) {
        self.eastE6 = Int(x*1E6)
    }
    
    func setWest(x :Double) {
        self.westE6 = Int(x*1E6)
    }
    
    func setNorth(x :Double) {
        self.northE6 = Int(x*1E6)
    }
    
    func setSouth(x :Double) {
        self.southE6 = Int(x*1E6)
    }
    
    func setEastE6(x :Int) {
        self.eastE6 = x
    }
    
    func setWestE6(x :Int) {
        self.westE6 = x
    }
    
    func setNorthE6(x :Int) {
        self.northE6 = x
    }
    
    func setSouthE6(x :Int) {
        self.southE6 = x    }
}

class GeoPointImpl : NSObject, GeoPointMutable {
    var latitude  : Double = 0.0
    var longitude : Double = 0.0
    
    func getLatitude() -> Double {
        return latitude
    }
    func getLongitude() -> Double {
        return longitude
    }
    func setLatitude(lat: Double) {
        self.latitude = lat
    }
    func setLongitude(lon: Double) {
        self.longitude = lon
    }
    func getX() -> Double {
        return self.longitude
    }
    func getY() -> Double {
        return self.latitude
    }

    override init() {
        super.init()
    }
    
    init(geoPoint: GeoPoint) {
        self.longitude = geoPoint.getLongitude()
        self.latitude = geoPoint.getLatitude()
        super.init()
    }
    
    init( coder : NSCoder ) {
        super.init()
        initWithCoder(coder)
    }
    
    func set(lat: Double, lon: Double) -> GeoPointMutable {
        self.latitude = lat
        self.longitude = lon
        return self
    }
    
    init(lat : Double, lon : Double) {
        super.init()
        setLatitude(lat)
        setLongitude(lon)
    }
    
    func initWithCoder(decoder : NSCoder) {
        self.latitude = decoder.decodeDoubleForKey("lat")
        self.longitude = decoder.decodeDoubleForKey("lon")
    }
    
    func encodeWithCoder(encoder : NSCoder) {
        encoder.encodeDouble(latitude, forKey: "lat")
        encoder.encodeDouble(longitude, forKey: "lon")
    }
}

class DGeoPoint {
    var geoPoint : GeoPoint
    var bearing : Double
    var distance : Double
    var index : Int
    init(point : GeoPoint, b: Double, d :Double, i : Int) {
        self.geoPoint = point
        self.bearing  = b
        self.distance = d
        self.index = i
    }
}

class GeoRect : NSObject {
    var left : Double
    var top : Double
    var right : Double
    var bottom : Double
    
    init( coder : NSCoder ) {
        self.left = coder.decodeDoubleForKey("left")
        self.top = coder.decodeDoubleForKey("top")
        self.right = coder.decodeDoubleForKey("right")
        self.bottom = coder.decodeDoubleForKey("bottom")
    }
    
    init(left : Double, top : Double, right : Double, bottom : Double) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
        super.init()
    }
    
    init(boundingBox : BoundingBox) {
        self.top = boundingBox.north()
        self.left = boundingBox.west()
        self.right = boundingBox.east()
        self.bottom = boundingBox.south()
        super.init()
    }
    
    func encodeWithCoder(encoder : NSCoder) {
        encoder.encodeDouble(left, forKey: "left")
        encoder.encodeDouble(top, forKey: "top")
        encoder.encodeDouble(right, forKey: "right")
        encoder.encodeDouble(bottom, forKey: "bottom")
    }
    func center() -> GeoPoint {
        return GeoPointImpl(lat: (left + right)/2, lon: (top + bottom)/2)
    }
    func height() -> Double {
        return bottom - top
    }
    func width() -> Double {
        return right - left
    }
}

class Path  {
    var cgpath : CGMutablePath = CGPathCreateMutable()
    var transform = CGAffineTransform(a: 1,b: 1,c: 1,d: 1,tx: 0,ty: 0)
    var segments = 0
    var points = 0
    init() {
    }
    private var empty : Bool = true
    
    func isEmpty() -> Bool {
        return empty;
    }
    func moveTo(x: Double, y: Double) {
        moveTo(Float(x), y: Float(y))
    }
    func moveTo(x: Float, y: Float) {
        self.empty = false
        self.segments += 1
        self.points += 1
        CGPathMoveToPoint(self.cgpath, nil, CGFloat(x), CGFloat(y))
    }
    func lineTo(x: Double, y: Double) {
        lineTo(Float(x), y: Float(y))
    }
    func lineTo(x: Float, y: Float) {
        self.empty = false
        self.points += 1
        CGPathAddLineToPoint(self.cgpath, nil, CGFloat(x), CGFloat(y))
    }
}

struct GeoCalc {
    static let LAT_PER_FOOT : Double =  2.738129E-6
    static let LON_PER_FOOT : Double = 2.738015E-6
    static let FEET_PER_KM : Double = 3280.84
    static let EARTH_RADIUS_FEET : Double = 6371.009 * FEET_PER_KM
    static let DEFAULT_PRECISION : Double = 1E6
    
    static func to_radians(deg : Double) -> Double {
        return deg * M_PI / 180.0
    }
    
    static func to_degrees(rad : Double) -> Double {
        return rad * (180.0 / M_PI)
    }
    
    static func to_sign(n : Double) -> Double {
        return n < 0.0 ? -1.0 : n == 0.0 ? 0.0 : 1.0
    }
    
    static func toGeoPoint(location : Location) -> GeoPoint {
        return GeoPointImpl(lat: location.latitude, lon: location.longitude)
    }

    static func equalCoordinates(c1 : GeoPoint, c2 : GeoPoint, prec: Double) -> Bool {
        let result = floor(c1.getLongitude()*prec) == floor(c2.getLongitude()*prec) &&
            floor(c1.getLatitude()*prec) == floor(c2.getLatitude()*prec)
        return result
    }

    static func equalCoordinates(c1 : GeoPoint, c2 : GeoPoint) -> Bool {
        return equalCoordinates(c1, c2: c2, prec: DEFAULT_PRECISION)
    }
    
    static func getCentralAngleHaversine(c1: GeoPoint, c2: GeoPoint) -> Double {
        let dlon = to_radians(c2.getLongitude() - c1.getLongitude())
        let dlat = to_radians(c2.getLatitude() - c1.getLatitude())
        let lat1 = to_radians(c1.getLatitude())
        let lat2 = to_radians(c2.getLatitude())
        
        let a = sin(dlat/2.0) * sin(dlat/2.0) + sin(dlon/2.0) * sin(dlon/2.0) * cos(lat1) * cos(lat2)
        let angle = 2 * atan2(sqrt(a), sqrt(1-a))
        return angle
    }
    
    static func getCentralAngle(c1: GeoPoint, c2: GeoPoint) -> Double {
        return getCentralAngleHaversine(c1, c2: c2)
    }
    
    // Returns the distance between two locations in feet.
    static func getGeoDistance(c1 : GeoPoint, c2 : GeoPoint) -> Double {
        if equalCoordinates(c1, c2: c2) {
            return 0.0
        }
        let ca = getCentralAngle(c1, c2: c2)
        let dist = EARTH_RADIUS_FEET * ca
        let result = abs(dist)
        return result
    }
    
    static func getGeoAngle(c1 : GeoPoint, c2 : GeoPoint) -> Double {
        var x = c2.getLongitude() - c1.getLongitude()
        var y = c2.getLatitude() - c1.getLatitude()
        y = y <= -180 ? y + 360 : y
        y = y >= 180 ? y - 360 : y

        let nw = GeoPointImpl(lat: c1.getLatitude(), lon: c2.getLongitude())

        let ca1 = getCentralAngle(c1, c2: nw)
        let dist1 = EARTH_RADIUS_FEET * ca1 * to_sign(x)
        let ca2 = getCentralAngle(c2, c2: nw)
        let dist2 = EARTH_RADIUS_FEET * ca2 * to_sign(y)
        let result = atan2(dist2, dist1)
        return result
    }
    
    
    static func getBearing(gp1 : GeoPoint, gp2 : GeoPoint) -> Double {
        let lat1 = GeoCalc.to_radians(gp1.getLatitude())
        let long1 = GeoCalc.to_radians(gp1.getLongitude())
        let lat2 = GeoCalc.to_radians(gp2.getLatitude())
        let long2 = GeoCalc.to_radians(gp2.getLongitude())
        let delta_long = long2 - long1
        let a = sin(delta_long) * cos(lat2)
        let b = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(delta_long)
        let bearing = GeoCalc.to_degrees(atan2(a,b))
        let bearing_normalized = (bearing + 360) % 360
        return bearing_normalized
    }
    
    // Distance in feet
    static func getGeoPointByBearingAndDistance(point : GeoPoint, bearing : Double, distance: Double) -> DGeoPoint {
        let lat1 = GeoCalc.to_radians(point.getLatitude())
        let lon1 = GeoCalc.to_radians(point.getLongitude())
        let brad = GeoCalc.to_radians(bearing)

        let angularDistance = distance / GeoCalc.EARTH_RADIUS_FEET
        let lat2 = asin( sin(lat1)*cos(angularDistance) + cos(lat1)*sin(angularDistance)*cos(brad))
        let lon2 = lon1 + atan2(sin(brad)*sin(angularDistance)*cos(lat1), cos(angularDistance) - sin(lat1)*sin(lat2))
        let lat2d = GeoCalc.to_degrees(lat2)
        let lon2d = GeoCalc.to_degrees(lon2)
        let dpoint = DGeoPoint(point: GeoPointImpl(lat: lat2d, lon: lon2d), b: bearing, d: distance, i : -1)
        return dpoint
    }
    
    static func rotate(point : GeoPoint, pivot : GeoPoint, theta : Double, reuse : GeoPointMutable) -> GeoPoint {
        
        let lat : Double = cos(theta) * (point.getLatitude() - pivot.getLatitude()) - sin(theta) * (point.getLongitude() - pivot.getLongitude()) + pivot.getLatitude()
        
        let lon : Double = sin(theta) * (point.getLatitude() - pivot.getLatitude()) + cos(theta) * (point.getLongitude() - pivot.getLongitude()) + pivot.getLongitude()
        
        reuse.setLatitude(lat)
        reuse.setLongitude(lon)
        return reuse
    }

    
    static func rotate(point : GeoPoint, pivot : GeoPoint, theta : Double) -> GeoPoint {
        return rotate(point, pivot: pivot, theta: theta, reuse: GeoPointImpl())
    }    
    

    ////
    // The method defines a measure of the point c3 being off the line made by c1 to c2 in feet.
    // Point c3 is said to be within the bounds of c1 and c2 if its perpendicular height
    // line intersects with line in between c1 and c2.
    // If the point c3 is within the bounds of c1 and c2 then the offLine measurement is
    // the perpendicular distance from the line.
    // If point c3 is outside the bounds of c1 and c2, then the offLine measurement
    // is the height of an isosceles triangle (a=b,c) with c1 to c2 being the base (c), and keeping
    // the same perimeter distance, i.e. d(a) = d(b) = (d(c1,c3) + d(c3,c2))
    // This makes the measure more than its perpendicular distance from the line which would
    // intersect outside the bounds. For instance, if all coordinates had the same y, and
    // we had points c1(0,0) c2(1,0) c3(2,0), then the perpendicular distance from c1-c2 is 0, but
    // we are not between c1 and c2, so this function returns 1.4142135623730951 to signify the
    // off lineness
    //
    static func offLine(c1 : GeoPoint, c2 :GeoPoint, c3 : GeoPoint) -> Double {

        if equalCoordinates(c1,c2: c2) {
            return equalCoordinates(c1, c2: c3) ? 0 : getGeoDistance(c1, c2: c3)
        }

        if equalCoordinates(c1, c2: c3) {
            return 0
        }

        let theta1 = getGeoAngle(c1, c2: c2)

        // Rotate points around c1 to the horizontal line
        // We don't care about lats and lons outside of (-90,90), and (-180,180) respectively, at this point.
        // They are just numbers used for calculation of angles.
        let c2_1 = rotate(c2, pivot: c1, theta: -theta1)
        let c3_1 = rotate(c3, pivot: c1, theta: -theta1)

        //   buf                          buf
        // (---  c1 ----------------- c2 ---)
        //          *      |
        //   H(c1-c3) *    | H*Sin(theta3)
        //              *  |
        //                c3
        if (c1.getLongitude() <= c3_1.getLongitude() && c3_1.getLongitude() <= c2_1.getLongitude()) {
            let a3 = (c3_1.getLatitude() - c1.getLatitude())
            let b3 = (c3_1.getLongitude() - c1.getLongitude())
            let theta3 =  atan2(a3, b3)
            let hc1c3 = getGeoDistance(c1, c2: c3)
            return abs(hc1c3 * sin(theta3))
        }

        let hc1c3 = getGeoDistance(c1, c2: c3)
        let hc1c2 = getGeoDistance(c1, c2: c2)
        let hc2c3 = getGeoDistance(c2, c2: c3)
        //
        // in the case   c
        //      c1-----------------c2
        // a   *                *
        //    *          *
        //   *    *    b
        //  *
        // c3
        // We measure by making it an (a=b,c) isosceles triangle with the same perimeter. That is with sides
        // of a = b = (H(c1,c3) + H(c2,c3))/2, and c = H(c1,c2) then measure the height
        // by SQRT( a*a - (c/2)*(c/2)
        //
        let a = (hc1c3 + hc2c3)/2.0
        let b = a;
        let c = hc1c2
        let c_2 = c/2.0
        let off = sqrt(a*a - c_2*c_2)
        return off
    }
    
    // Returns true if point is on line within the buffer (in feet)
    static func isOnLine(c1 : GeoPoint, c2 : GeoPoint, buffer : Double, c3 : GeoPoint) -> Bool {
        return offLine(c1,c2: c2, c3: c3) < buffer
    
//        let theta1 = getGeoAngle(c1, c2: c2)
//        let theta2 = getGeoAngle(c1, c2: c3)
//        let theta3 = theta2-theta1
//        
//        let hclc3 = getGeoDistance(c1, c2: c3)
//        let hclc2 = getGeoDistance(c1, c2: c2)
//        
//        let result = hclc3 < buffer || abs(theta3) < M_PI/2.0 &&
//             hclc3 <= hclc2 + buffer/2.0 && abs(sin(theta3) * hclc3) <= buffer/2.0
//        return result
    }
    
    
    static func isOnPath(path : [GeoPoint], buffer : Double, c3 : GeoPoint) -> Bool {
        var p1 = path[0]
        var i = 1
        while (i < path.count) {
            let p2 = path[i]
            if isOnLine(p1, c2: p2, buffer: buffer, c3: c3) {
                return true
            }
            p1 = p2
            i += 1
        }
        return false
    }
    
    
    static func isOnPath(path : [CLLocationCoordinate2D], buffer : Double, c3 : GeoPoint) -> Bool {
        var p1 = path[0]
        var i = 1
        while (i < path.count) {
            let p2 = path[i]
            if isOnLine(p1, c2: p2, buffer: buffer, c3: c3) {
                return true
            }
            p1 = p2
            i += 1
        }
        return false
    }
    
    static func pathDistance(path : [GeoPoint]) -> Double {
        var dist = 0.0
        var p1 = path[0]
        var i = 1
        while (i < path.count) {
            let p2 = path[i]
            dist += getGeoDistance(p1, c2: p2)
            p1 = p2
            i += 1
        }
        return dist
    }
    
    // You gotta be kidding me. Doesn't anybody in this language understand type systems?
    // It can do a single CLLocationCoordinate2D to GeoPoint, but can't do that
    // with [CLLocationCoordinate2D] to [GeoPoint]. So, we have to recreate the function.
    
    static func pathDistance(path : [CLLocationCoordinate2D]) -> Double {
        var dist = 0.0
        var p1 = path[0]
        var i = 1
        while (i < path.count) {
            let p2 = path[i]
            dist += getGeoDistance(p1 as GeoPoint, c2: p2 as GeoPoint)
            p1 = p2
            i += 1
        }
        return dist
    }
}

struct GeoPathUtils {
    
    static func getDistance(path : [GeoPoint]) -> Double {
        return GeoCalc.pathDistance(path);
    }
    
    static func getDistance(path : [CLLocationCoordinate2D]) -> Double {
        return GeoCalc.pathDistance(path);
    }
    
    static func getGeoDistance(c1 : GeoPoint, c2 : GeoPoint) -> Double {
        return GeoCalc.getGeoDistance(c1, c2: c2)
    }
    
    static func getCentralAngle(c1 : GeoPoint, c2 : GeoPoint) -> Double {
        return GeoCalc.getCentralAngle(c1, c2: c2)
    }
    
    static func getGeoAngle(c1 : GeoPoint, c2 : GeoPoint) -> Double {
        return GeoCalc.getGeoAngle(c1, c2: c2)
    }
    
    static func isOnLine(c1 : GeoPoint, c2 : GeoPoint, buffer : Double, c3 : GeoPoint) -> Bool {
        return GeoCalc.isOnLine(c1, c2: c2, buffer: buffer, c3: c3)
    }
    
    static func isOnPath(path : [GeoPoint], buffer : Double, c3 : GeoPoint) -> Bool {
        return GeoCalc.isOnPath(path, buffer: buffer, c3: c3)
    }
    
    static func isOnPath(path : [CLLocationCoordinate2D], buffer : Double, c3 : GeoPoint) -> Bool {
        return GeoCalc.isOnPath(path, buffer: buffer, c3: c3)
    }
    
    static func offPath(path : [GeoPoint], point : GeoPoint) -> Double {
        var min = GeoCalc.EARTH_RADIUS_FEET * GeoCalc.EARTH_RADIUS_FEET * M_PI
        var last : GeoPoint? = nil
        if (path.count > 0) {
            last = path[0]
        }
        for(var i = 1; i < path.count-1; i++) {
            var p = path[i]
            let off =  GeoCalc.offLine(last!, c2: p, c3: point)
            if (off < min) {
                min = off
            }
            last = p
        }
        return min
    }
    
    static func whereOnPath(path : [GeoPoint], buffer : Double, point : GeoPoint) -> [DGeoPoint] {
        var results = [DGeoPoint]()
        var distance = 0.0
        var p1 = path[0]
        for(var i = 1; i < path.count-1; i++) {
            var p2 = path[i]
            let maxdist = GeoCalc.getGeoDistance(p1, c2: p2)
            //if isOnLine(p1, c2: p2, buffer: buffer, c3: c3) {
            let offPath = GeoCalc.offLine(p1, c2: p2, c3: point)
            if offPath < buffer {
                let dist = min(maxdist, GeoCalc.getGeoDistance(p1, c2: point))
                let bearing = GeoCalc.getBearing(point, gp2: p2)
                results.append(DGeoPoint(point: point, b: distance + dist, d: bearing, i: i))
                distance += maxdist
            } else {
                distance += maxdist
            }
            p1 = p2
        }
        return results
    }
    
    static func whereOnPath(path : [CLLocationCoordinate2D], buffer : Double, c3 : GeoPoint) -> [DGeoPoint] {
        var results = [DGeoPoint]()
        var distance = 0.0
        var p1 = path[0]
        for(var i = 1; i < path.count-1; i++) {
            var p2 = path[i]
            if isOnLine(p1, c2: p2, buffer: buffer, c3: c3) {
                let dist = GeoCalc.getGeoDistance(p1, c2: c3)
                let bearing = GeoCalc.getBearing(c3, gp2: p2)
                results.append(DGeoPoint(point: c3, b: distance + dist, d: bearing, i: i))
                distance += GeoCalc.getGeoDistance(p1, c2: p2)
            } else {
                distance += GeoCalc.getGeoDistance(p1, c2: p2)
            }
            p1 = p2
        }
        return results
    }
    
    static func whereOnPathByDistance(path : [GeoPoint], distance: Double) -> DGeoPoint? {
        var p1 = path[0]
        var currentDistance = 0.0
        for(var i = 1; i < path.count-1; i++) {
            var p2 = path[i]
            let dist = currentDistance + GeoCalc.getGeoDistance(p1, c2: p2)
            if currentDistance <= distance && distance < currentDistance + dist {
                let bearing = GeoCalc.getBearing(p1, gp2: p2)
                let dpoint = GeoCalc.getGeoPointByBearingAndDistance(p1, bearing: bearing, distance: distance - currentDistance)
                dpoint.distance += currentDistance
                return dpoint
            }
            currentDistance += dist
            p1 = p2
        }
        return nil
    }
    
    static func rectForPath(path : [GeoPoint]) -> GeoRect {
        var left = path[0].getLongitude()
        var bottom = path[0].getLatitude()
        var right = left
        var top = bottom

        for (var i = 1; i < (path.count-1); i++) {
            // TODO This is wrong if we span the date line
            left = min(left, path[i].getLongitude())
            right = max(right, path[i].getLongitude())
            top = max(top, path[i].getLatitude())
            bottom = min(bottom, path[i].getLatitude())
        }
        return GeoRect(left: left, top: top, right: right, bottom: bottom)
    }
    
    static func rectForPath(path : [CLLocationCoordinate2D]) -> GeoRect {
        var left = path[0].longitude
        var bottom = path[0].latitude
        var right = left
        var top = bottom
        
        for (var i = 1; i < (path.count-1); i++) {
            // TODO This is wrong if we span the date line
            left = min(left, path[i].latitude)
            right = max(right, path[i].longitude)
            top = max(top, path[i].latitude)
            bottom = min(bottom, path[i].longitude)
        }
        return GeoRect(left: left, top: top, right: right, bottom: bottom)
    }
    
    static func unionGeoRect(rect1 : GeoRect, rect2: GeoRect) -> GeoRect {
        let left = min(rect1.left, rect2.left)
        let right = max(rect1.right, rect2.right)
        let top = max(rect1.top, rect2.top)
        let bottom = min(rect1.bottom, rect2.bottom)
        return GeoRect(left: left, top: top, right: right, bottom: bottom)
    }
    
}
