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

public protocol GeoPoint {
    func getLatitude() -> Double
    func getLongitude() -> Double
}


public protocol GeoPointMutable : GeoPoint {
    func setLatitude(lat : Double)
    func setLongitude(lon :Double)
    func set(lat : Double, lon : Double) -> GeoPointMutable
}

public class BoundingBox {
    public var eastE6 : Int = 0
    public var westE6 : Int = 0
    public var northE6 : Int = 0
    public var southE6 : Int = 0
    
    
    public init(array: [String]) {
        setNorth((array[0] as NSString).doubleValue)
        setEast((array[1] as NSString).doubleValue)
        setWest((array[2] as NSString).doubleValue)
        setSouth((array[3] as NSString).doubleValue)
    }

    public init(north: Double, east: Double, west: Double, south : Double) {
        setNorth(north)
        setEast(east)
        setWest(west)
        setSouth(south)
    }
    
    public init(northE6: Int, eastE6: Int, westE6: Int, southE6: Int) {
        setNorthE6(northE6)
        setEastE6(eastE6)
        setWestE6(westE6)
        setSouthE6(southE6)
    }
    
    public func toGeoRect() -> GeoRect {
        return GeoRect(left: west(), top: north(), right: east(), bottom: south())
    }
    
    func initWithCoder( coder : NSCoder) {
        self.eastE6 = Int(coder.decodeIntForKey("eastE6"))
        self.westE6 = Int(coder.decodeIntForKey("westE6"))
        self.northE6 = Int(coder.decodeIntForKey("northE6"))
        self.southE6 = Int(coder.decodeIntForKey("southE6"))
    }
    
    public func encodeWithCoder( coder : NSCoder) {
        coder.encodeInt(Int32(eastE6), forKey: "eastE6")
        coder.encodeInt(Int32(westE6), forKey: "westE6")
        coder.encodeInt(Int32(southE6), forKey: "southE6")
        coder.encodeInt(Int32(northE6), forKey: "northE6")
    }
    
    public func east() -> Double {
        return Double(eastE6) * 1E6
    }
    
    public func west() -> Double {
        return Double(westE6) * 1E6
    }
    
    public func north() -> Double {
        return Double(northE6) * 1E6
    }
    
    public func south() -> Double {
        return Double(southE6) * 1E6
    }
    
    public func setEast(x :Double) {
        self.eastE6 = Int(x/1E6)
    }
    
    public func setWest(x :Double) {
        self.eastE6 = Int(x/1E6)
    }
    
    public func setNorth(x :Double) {
        self.eastE6 = Int(x/1E6)
    }
    
    public func setSouth(x :Double) {
        self.eastE6 = Int(x/1E6)
    }
    
    public func setEastE6(x :Int) {
        self.eastE6 = x
    }
    
    public func setWestE6(x :Int) {
        self.eastE6 = x
    }
    
    public func setNorthE6(x :Int) {
        self.eastE6 = x
    }
    
    public func setSouthE6(x :Int) {
        self.eastE6 = x    }
}

public class GeoPointImpl : GeoPointMutable {
    public var latitude  : Double = 0.0
    public var longitude : Double = 0.0
    
    public func getLatitude() -> Double {
        return latitude
    }
    public func getLongitude() -> Double {
        return longitude
    }
    public func setLatitude(lat: Double) {
        self.latitude = lat
    }
    public func setLongitude(lon: Double) {
        self.longitude = lon
    }

    public init() {
    }
    
    public func set(lat: Double, lon: Double) -> GeoPointMutable {
        self.latitude = lat
        self.longitude = lon
        return self
    }
    
    public init(lat : Double, lon : Double) {
        setLatitude(lat)
        setLongitude(lon)
    }
    
    func initWithCoder(decoder : NSCoder) {
        self.latitude = decoder.decodeDoubleForKey("lat")
        self.longitude = decoder.decodeDoubleForKey("lon")
    }
    
    public func encodeWithCoder(encoder : NSCoder) {
        encoder.encodeDouble(latitude, forKey: "lat")
        encoder.encodeDouble(longitude, forKey: "lon")
    }
}

public class DGeoPoint {
    public var geoPoint : GeoPoint
    public var bearing : Double
    public var distance : Double
    public init(point : GeoPoint, b: Double, d :Double) {
        self.geoPoint = point
        self.bearing  = b
        self.distance = d
    }
}

public class GeoRect {
    public var left : Double
    public var top : Double
    public var right : Double
    public var bottom : Double
    
    public init(left : Double, top : Double, right : Double, bottom : Double) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
    }
    
    func initWithCoder(decoder : NSCoder) {
        self.left = decoder.decodeDoubleForKey("left")
        self.top = decoder.decodeDoubleForKey("top")
        self.right = decoder.decodeDoubleForKey("right")
        self.bottom = decoder.decodeDoubleForKey("bottom")
    }
    
    public func encodeWithCoder(encoder : NSCoder) {
        encoder.encodeDouble(left, forKey: "left")
        encoder.encodeDouble(top, forKey: "top")
        encoder.encodeDouble(right, forKey: "right")
        encoder.encodeDouble(bottom, forKey: "bottom")
    }
    public func center() -> GeoPoint {
        return GeoPointImpl(lat: (left + right)/2, lon: (top + bottom)/2)
    }
    public func height() -> Double {
        return bottom - top
    }
    public func width() -> Double {
        return right - left
    }
}

public class Path  {
    public var cgpath : CGMutablePath = CGPathCreateMutable()
    public var transform = CGAffineTransform(a: 1,b: 1,c: 1,d: 1,tx: 0,ty: 0)

    public init() {
    }
    private var empty : Bool = true
    
    public func isEmpty() -> Bool {
        return empty;
    }
    public func moveTo(x: Double, y: Double) {
        moveTo(Float(x), y: Float(y))
    }
    public func moveTo(x: Float, y: Float) {
        self.empty = false
        CGPathMoveToPoint(self.cgpath, &self.transform, CGFloat(x), CGFloat(y))
    }
    public func lineTo(x: Double, y: Double) {
        lineTo(Float(x), y: Float(y))
    }
    public func lineTo(x: Float, y: Float) {
        self.empty = false
        CGPathMoveToPoint(self.cgpath, &self.transform, CGFloat(x), CGFloat(y))
    }
}

public struct GeoCalc {
    public static let LAT_PER_FOOT : Double =  2.738129E-6
    public static let LON_PER_FOOT : Double = 2.738015E-6
    public static let FEET_PER_KM : Double = 3280.84
    public static let EARTH_RADIUS_FEET : Double = 6371.009 * FEET_PER_KM
    public static let DEFAULT_PRECISION : Double = 1E6
    
    public static func to_radians(deg : Double) -> Double {
        return deg * M_PI / 180.0
    }
    
    public static func to_degrees(rad : Double) -> Double {
        return rad * (180.0 / M_PI)
    }
    
    public static func to_sign(n : Double) -> Double {
        return n < 0.0 ? -1.0 : n == 0.0 ? 0.0 : 1.0
    }
    
    public static func toGeoPoint(location : Location) -> GeoPoint {
        return GeoPointImpl(lat: location.latitude, lon: location.longitude)
    }

    public static func equalCoordinates(c1 : GeoPoint, c2 : GeoPoint, prec: Double) -> Bool {
        let result = floor(c1.getLongitude()*prec) == floor(c2.getLongitude()*prec) &&
            floor(c1.getLatitude()*prec) == floor(c2.getLatitude()*prec)
        return result
    }

    public static func equalCoordinates(c1 : GeoPoint, c2 : GeoPoint) -> Bool {
        return equalCoordinates(c1, c2: c2, prec: DEFAULT_PRECISION)
    }
    
    public static func getCentralAngleHaversine(c1: GeoPoint, c2: GeoPoint) -> Double {
        let dlon = to_radians(c2.getLongitude() - c1.getLongitude())
        let dlat = to_radians(c2.getLatitude() - c1.getLatitude())
        let lat1 = to_radians(c1.getLatitude())
        let lat2 = to_radians(c2.getLatitude())
        
        let a = sin(dlat/2.0) * sin(dlat/2.0) + sin(dlon/2.0) * sin(dlon/2.0) * cos(lat1) * cos(lat2)
        let angle = 2 * atan2(sqrt(a), sqrt(1-a))
        return angle
    }
    
    public static func getCentralAngle(c1: GeoPoint, c2: GeoPoint) -> Double {
        return getCentralAngleHaversine(c1, c2: c2)
    }
    
    // Returns the distance between two locations in feet.
    public static func getGeoDistance(c1 : GeoPoint, c2 : GeoPoint) -> Double {
        if equalCoordinates(c1, c2: c2) {
            return 0.0
        }
        let ca = getCentralAngle(c1, c2: c2)
        let dist = EARTH_RADIUS_FEET * ca
        let result = abs(dist)
        return result
    }
    
    public static func getGeoAngle(c1 : GeoPoint, c2 : GeoPoint) -> Double {
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
    
    
    public static func getBearing(gp1 : GeoPoint, gp2 : GeoPoint) -> Double {
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
    
    public static func rotate(point : GeoPoint, pivot : GeoPoint, theta : Double, reuse : GeoPointMutable) -> GeoPoint {
        
        let lat : Double = cos(theta) * (point.getLatitude() - pivot.getLatitude()) - sin(theta) * (point.getLongitude() - pivot.getLongitude()) + pivot.getLatitude()
        
        let lon : Double = sin(theta) * (point.getLatitude() - pivot.getLatitude()) + cos(theta) * (point.getLongitude() - pivot.getLongitude()) + pivot.getLongitude()
        
        reuse.setLatitude(lat)
        reuse.setLongitude(lon)
        return reuse
    }

    
    public static func rotate(point : GeoPoint, pivot : GeoPoint, theta : Double) -> GeoPoint {
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
    public static func offLine(c1 : GeoPoint, c2 :GeoPoint, c3 : GeoPoint) -> Double {

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
    public static func isOnLine(c1 : GeoPoint, c2 : GeoPoint, buffer : Double, c3 : GeoPoint) -> Bool {
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
    
    
    public static func isOnPath(path : [GeoPoint], buffer : Double, c3 : GeoPoint) -> Bool {
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
    
    
    public static func isOnPath(path : [CLLocationCoordinate2D], buffer : Double, c3 : GeoPoint) -> Bool {
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
    
    public static func pathDistance(path : [GeoPoint]) -> Double {
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
    
    public static func pathDistance(path : [CLLocationCoordinate2D]) -> Double {
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

public struct GeoPathUtils {
    
    public static func getDistance(path : [GeoPoint]) -> Double {
        return GeoCalc.pathDistance(path);
    }
    
    public static func getDistance(path : [CLLocationCoordinate2D]) -> Double {
        return GeoCalc.pathDistance(path);
    }
    
    public static func getGeoDistance(c1 : GeoPoint, c2 : GeoPoint) -> Double {
        return GeoCalc.getGeoDistance(c1, c2: c2)
    }
    
    public static func getCentralAngle(c1 : GeoPoint, c2 : GeoPoint) -> Double {
        return GeoCalc.getCentralAngle(c1, c2: c2)
    }
    
    public static func getGeoAngle(c1 : GeoPoint, c2 : GeoPoint) -> Double {
        return GeoCalc.getGeoAngle(c1, c2: c2)
    }
    
    public static func isOnLine(c1 : GeoPoint, c2 : GeoPoint, buffer : Double, c3 : GeoPoint) -> Bool {
        return GeoCalc.isOnLine(c1, c2: c2, buffer: buffer, c3: c3)
    }
    
    public static func isOnPath(path : [GeoPoint], buffer : Double, c3 : GeoPoint) -> Bool {
        return GeoCalc.isOnPath(path, buffer: buffer, c3: c3)
    }
    
    public static func isOnPath(path : [CLLocationCoordinate2D], buffer : Double, c3 : GeoPoint) -> Bool {
        return GeoCalc.isOnPath(path, buffer: buffer, c3: c3)
    }
    
    public static func offPath(path : [GeoPoint], point : GeoPoint) -> Double {
        var max = GeoCalc.EARTH_RADIUS_FEET * GeoCalc.EARTH_RADIUS_FEET * M_PI
        var last : GeoPoint? = nil
        if (path.count > 0) {
            last = path[0]
        }
        for p in path {
            let off =  GeoCalc.offLine(last!, c2: p, c3: point)
            if (off < max) {
                max = off
            }
            last = p
        }
        return max
    }
    
    public static func whereOnPath(path : [GeoPoint], buffer : Double, c3 : GeoPoint) -> [DGeoPoint] {
        var results = [DGeoPoint]()
        var distance = 0.0
        var p1 = path[0]
        var i = 1
        for(var p2 = path[i]; i < path.count-1; i++) {
            if isOnLine(p1, c2: p2, buffer: buffer, c3: c3) {
                let dist = GeoCalc.getGeoDistance(p1, c2: c3)
                let bearing = GeoCalc.getBearing(c3, gp2: p2)
                results.append(DGeoPoint(point: c3, b: distance + dist, d: bearing))
                distance += GeoCalc.getGeoDistance(p1, c2: p2)
            } else {
                distance += GeoCalc.getGeoDistance(p1, c2: p2)
            }
            p1 = p2
            i += 1
        }
        return results
    }
    
    public static func whereOnPath(path : [CLLocationCoordinate2D], buffer : Double, c3 : GeoPoint) -> [DGeoPoint] {
        var results = [DGeoPoint]()
        var distance = 0.0
        var p1 = path[0]
        var i = 1
        for(var p2 = path[i]; i < path.count-1; i++) {
            if isOnLine(p1, c2: p2, buffer: buffer, c3: c3) {
                let dist = GeoCalc.getGeoDistance(p1, c2: c3)
                let bearing = GeoCalc.getBearing(c3, gp2: p2)
                results.append(DGeoPoint(point: c3, b: distance + dist, d: bearing))
                distance += GeoCalc.getGeoDistance(p1, c2: p2)
            } else {
                distance += GeoCalc.getGeoDistance(p1, c2: p2)
            }
            p1 = p2
            i += 1
        }
        return results
    }
    
    
    public static func rectForPath(path : [GeoPoint]) -> GeoRect {
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
    
    public static func rectForPath(path : [CLLocationCoordinate2D]) -> GeoRect {
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
    
}
