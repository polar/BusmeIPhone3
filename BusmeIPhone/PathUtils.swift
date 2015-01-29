//
//  PathUtils.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/10/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import MapKit


// PointImpl is an extension of a native type.

struct Rect {
    let ORIENT_UL = 0
    let ORIENT_LL = 1
    var left : Double
    var top : Double
    var right : Double
    var bottom : Double
    var orient : Int = 0 // ORIENT_UL
    
    init(left: Float, top : Float, right: Float, bottom : Float) {
        self.left = Double(left)
        self.top = Double(top)
        self.right = Double(right)
        self.bottom = Double(bottom)
    }
    
    init(left: Double, top : Double, right : Double, bottom : Double) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
    }
    
    init(boundingBox : BoundingBox) {
        self.left = boundingBox.west()
        self.top = boundingBox.north()
        self.right = boundingBox.east()
        self.bottom = boundingBox.south()
    }
    
    init(mapRect : MKMapRect) {
        // MapRect is Upper Left Oriented and increasing right down
        self.left = mapRect.origin.x
        self.top = mapRect.origin.y
        self.right = left + mapRect.size.width
        self.bottom = top + mapRect.size.height
    }
    
    
    init(cgRect : CGRect) {
        // CGREct is Lower Left Oriented and increasing right up
        self.left = Double(cgRect.origin.x)
        self.bottom = Double(cgRect.origin.y)
        self.top = Double(cgRect.origin.y + cgRect.size.height)
        self.right = left + Double(cgRect.size.width)
        self.orient = ORIENT_LL
    }
    
    init(geoRect : GeoRect) {
        self.left = geoRect.left
        self.right = geoRect.right
        self.top = geoRect.top
        self.bottom = geoRect.bottom
    }
    
    func dup() -> Rect {
        return Rect(left: left, top: top, right: right, bottom: bottom)
    }
    
    func center() -> Point {
        return PointImpl(x: (left + right)/2, y: (top + bottom)/2)
    }
    
    func width() -> Double {
        return right - left
    }
    
    func height() -> Double {
        return orient == ORIENT_UL ? top - bottom : bottom - top
    }
    
    func area() -> Double {
        return width() * height()
    }
    
    mutating func offsetTo(x : Double, y : Double) {
        self.left += x
        self.right += x
        self.top += y
        self.bottom += y
    }
    
    mutating func setWidthCenter(width : Double) {
        let left = (self.right - self.left)/2.0 - width/2.0
        let right = (self.right - self.left)/2.0 + width/2.0
        self.left = left
        self.right = right
    }
    
    mutating func setHeightCenter(height : Double) {
        let top = (self.top - self.bottom)/2.0 - height/2.0
        let bottom = (self.top - self.bottom)/2.0 + height/2.0
        self.top = top
        self.bottom = bottom
    }
    
    mutating func setWidthHeightCenter(width : Double, height : Double) {
        setWidthCenter(width)
        setHeightCenter(height)
    }
    
    mutating func setWidthHeight(width: Double, height : Double) {
        self.right = self.left + width
        self.bottom = self.top + height
    }
    
    func containsXY(x : Float, y : Float) -> Bool {
        return containsXY(Double(x), y: Double(y))
    }
    
    func containsXY(x : Double, y : Double) -> Bool {
        let xint = floor(x*1E6)
        let yint = floor(y*1E6)
        let horizontal = floor(left*1E6) <= xint && xint <= floor(right*1E6)
        let vertical = floor(bottom*1E6) <= yint && yint <= floor(top*1E6)
        return horizontal && vertical
    }
    
    func containsPoint(point : Point) -> Bool {
        return containsXY(point.getX(), y: point.getY())
    }
    
    func intersectRect(rect :Rect) -> Bool {
        return rect.containsXY(left, y: top) ||
            rect.containsXY(right, y:  top) ||
            rect.containsXY(left, y: bottom) ||
            rect.containsXY(right, y: bottom) ||
            self.containsXY(rect.left, y: rect.top) ||
            self.containsXY(rect.right, y: rect.top) ||
            self.containsXY(rect.left, y: rect.bottom) ||
            self.containsXY(rect.right, y: rect.bottom)
    }
    
    func intersecsLine(c1 : Point, c2 : Point) -> Bool {
        // Completely Outside
        if (c1.getX() <= left && c2.getX() <= left) || (c1.getY() <= bottom && c2.getY() <= bottom) || (right <= c1.getX() && right <= c2.getX()) || (top <= c1.getY() && top <= c2.getY()) {
            return false
        }
        let m = (c2.getY() - c1.getY())/(c2.getX() - c2.getX())
        let y = m * (left - c1.getX()) + c1.getY()
        if ( y > bottom && y < top) { return true }
        
        let y2 = m * (right - c1.getX()) + c1.getY()
        if ( y2 > bottom && y2 < top) { return true }
        
        let x = (bottom - c1.getY())/m + c1.getX()
        if ( x > left && x < right) { return true }
        
        let x2 = (top - c1.getY())/m + c1.getX()
        if ( x2 > left && x2 < right) { return true }
        return false
    }
    
    func toString() -> String {
        return "Rect(left:\(left),top:\(top),right:\(right),bottom:\(bottom))"
    }
}

protocol Point {
    func getX() -> Double
    func getY() -> Double
}

protocol PointMutable : Point {
    mutating func setX(x : Float)
    mutating func setY(y : Float)
    
    mutating func setX(x : Double)
    mutating func setY(y : Double)
    mutating func set(x : Double, y: Double) -> PointMutable
    mutating func set(x : Float, y: Float) -> PointMutable
}

struct PathUtils {
    static func isOnPath(points : [Point], rect : Rect) -> Bool {
        if points.count == 0 {
            return false
        }
        if points.count == 1 {
            return rect.containsXY(points[0].getX(), y: points[0].getY())
        }
        var last = points[0]
        for point in points {
            if rect.intersecsLine(last, c2: point) {
                return true
            }
            last = point
        }
        return false
    }
}
