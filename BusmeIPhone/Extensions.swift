//
//  Extensions.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/10/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation
import CoreGraphics
import MapKit


extension CLLocationCoordinate2D : GeoPoint {
    
    func getLatitude() -> Double {
        return latitude
    }
    func getLongitude() -> Double {
        return longitude
    }
    func getX() -> Double  {
        return longitude
    }
    func getY() -> Double{
        return latitude
    }
}

extension CGPoint : PointMutable {
    
    func getX() -> Double {
        return Double(x)
    }
    func getY() -> Double {
        return Double(y)
    }
    mutating func setX(x : Double) {
        self.x = CGFloat(x)
    }
    
    mutating func setX(x : Float) {
        self.x = CGFloat(x)
    }
    mutating func setY(y : Double) {
        self.y = CGFloat(y)
    }
    
    mutating func setY(y : Float) {
        self.y = CGFloat(y)
    }
    mutating func set(x : Double, y: Double) -> PointMutable {
        self.x = CGFloat(x)
        self.y = CGFloat(y)
        return self
    }
    
    mutating func set(x : Float, y: Float) -> PointMutable {
        self.x = CGFloat(x)
        self.y = CGFloat(y)
        return self
    }
}

typealias PointImpl = CGPoint

extension MKMapPoint : PointMutable {
    
    func getX() -> Double {
        return Double(x)
    }
    func getY() -> Double {
        return Double(y)
    }
    
    mutating func setX(x : Double) {
        self.x = Double(x)
    }
    
    mutating func setX(x : Float) {
        self.x = Double(x)
    }
    mutating func setY(y : Double) {
        self.y = Double(y)
    }
    
    mutating func setY(y : Float) {
        self.y = Double(y)
    }
    mutating func set(x : Double, y: Double) -> PointMutable {
        self.x = Double(x)
        self.y = Double(y)
        return self
    }
    
    mutating func set(x : Float, y: Float) -> PointMutable {
        self.x = Double(x)
        self.y = Double(y)
        return self
    }
}

extension Rect {
    func toCGRect() -> CGRect {
        return CGRect(x: CGFloat(left), y: CGFloat(bottom), width: CGFloat(right-left), height: CGFloat(top-bottom))
    }

}

extension GeoRect {
    func toMapRect() -> MKMapRect {
        let nw = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: self.top, longitude: self.left))
        let se = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: self.bottom, longitude: self.right))
        let nwMapRect = MKMapRect(origin: nw, size: MKMapSize(width: 0, height: 0))
        let seMapRect = MKMapRect(origin: se, size: MKMapSize(width: 0, height: 0))
        let result = MKMapRectUnion(nwMapRect, seMapRect)
        return result
    }

}

extension MKMapRect {
    func toString() -> String {
        return "Map\(Rect(mapRect: self).toString())"
    }
    
    func upperLeftQuadrant() -> MKMapRect {
        return MKMapRect(origin: origin, size: MKMapSize(width: size.width/2.0, height: size.height/2.0))
    }
    
    func lowerLeftQuadrant() -> MKMapRect {
        return MKMapRect(origin: MKMapPoint(x: origin.x, y: origin.y + size.height/2.0), size: MKMapSize(width: size.width/2.0, height: size.height/2.0))
    }
    
    func upperRightQuadrant() -> MKMapRect {
        return MKMapRect(origin: MKMapPoint(x: origin.x + size.width, y: origin.y), size: MKMapSize(width: size.width/2.0, height: size.height/2.0))
    }
    
    func lowerRightQuadrant() -> MKMapRect {
        return MKMapRect(origin: MKMapPoint(x: origin.x, y: origin.x + size.height/2.0), size: MKMapSize(width: size.width/2.0, height: size.height/2.0))
    }
}

extension ScreenPathUtils {
    static func cgRectToGeoRect(renderer : MKOverlayRenderer, cgRect : CGRect) -> GeoRect {
        let mapRect = renderer.mapRectForRect(cgRect)
        return mapRectToGeoRect(mapRect)
    }
    static func mapRectToGeoRect(mapRect : MKMapRect) -> GeoRect {
        let nw = MKCoordinateForMapPoint(mapRect.origin)
        let se = MKCoordinateForMapPoint(MKMapPoint(x: mapRect.origin.x + mapRect.size.width, y: mapRect.origin.y - mapRect.size.height))
        return GeoRect(left: nw.longitude, top: nw.latitude, right: se.longitude, bottom: se.latitude)
    }
}


