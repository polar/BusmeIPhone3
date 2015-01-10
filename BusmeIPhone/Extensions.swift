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
    
    public func getLatitude() -> Double {
        return latitude
    }
    public func getLongitude() -> Double {
        return longitude
    }
}

extension CGPoint : PointMutable {
    
    public func getX() -> Double {
        return Double(x)
    }
    public func getY() -> Double {
        return Double(y)
    }
    public mutating func setX(x : Double) {
        self.x = CGFloat(x)
    }
    
    public mutating func setX(x : Float) {
        self.x = CGFloat(x)
    }
    public mutating func setY(y : Double) {
        self.y = CGFloat(y)
    }
    
    public mutating func setY(y : Float) {
        self.y = CGFloat(y)
    }
    public mutating func set(x : Double, y: Double) -> PointMutable {
        self.x = CGFloat(x)
        self.y = CGFloat(y)
        return self
    }
    
    public mutating func set(x : Float, y: Float) -> PointMutable {
        self.x = CGFloat(x)
        self.y = CGFloat(y)
        return self
    }
}

typealias PointImpl = CGPoint

extension MKMapPoint : PointMutable {
    
    public func getX() -> Double {
        return Double(x)
    }
    public func getY() -> Double {
        return Double(y)
    }
    
    public mutating func setX(x : Double) {
        self.x = Double(x)
    }
    
    public mutating func setX(x : Float) {
        self.x = Double(x)
    }
    public mutating func setY(y : Double) {
        self.y = Double(y)
    }
    
    public mutating func setY(y : Float) {
        self.y = Double(y)
    }
    public mutating func set(x : Double, y: Double) -> PointMutable {
        self.x = Double(x)
        self.y = Double(y)
        return self
    }
    
    public mutating func set(x : Float, y: Float) -> PointMutable {
        self.x = Double(x)
        self.y = Double(y)
        return self
    }
}

extension Rect {
    public func toCGRect() -> CGRect {
        return CGRectMake(CGFloat(left), CGFloat(bottom), CGFloat(right-left), CGFloat(top-bottom))
    }

}

