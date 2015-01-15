//
//  PathUtils.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/10/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation


// PointImpl is an extension of a native type.

public struct Rect {
    public var left : Double
    public var top : Double
    public var right : Double
    public var bottom : Double
    
    public init(left: Float, top : Float, right: Float, bottom : Float) {
        self.left = Double(left)
        self.top = Double(top)
        self.right = Double(right)
        self.bottom = Double(bottom)
    }
    
    public init(left: Double, top : Double, right : Double, bottom : Double) {
        self.left = left
        self.top = top
        self.right = right
        self.bottom = bottom
    }
    
    public init(boundingBox : BoundingBox) {
        self.left = boundingBox.west()
        self.top = boundingBox.north()
        self.right = boundingBox.east()
        self.bottom = boundingBox.south()
    }
    
    public func dup() -> Rect {
        return Rect(left: left, top: top, right: right, bottom: bottom)
    }
    
    public func center() -> Point {
        return PointImpl(x: (left + right)/2, y: (top + bottom)/2)
    }
    
    public func width() -> Double {
        return right - left
    }
    
    public func height() -> Double {
        return bottom - top
    }
    
    public func area() -> Double {
        return width() * height()
    }
    
    public mutating func offsetTo(x : Double, y : Double) {
        self.left += x
        self.right += x
        self.top += y
        self.bottom += y
    }
    
    public mutating func setWidthCenter(width : Double) {
        let left = (self.right - self.left)/2.0 - width/2.0
        let right = (self.right - self.left)/2.0 + width/2.0
        self.left = left
        self.right = right
    }
    
    public mutating func setHeightCenter(height : Double) {
        let top = (self.top - self.bottom)/2.0 - height/2.0
        let bottom = (self.top - self.bottom)/2.0 + height/2.0
        self.top = top
        self.bottom = bottom
    }
    
    public mutating func setWidthHeightCenter(width : Double, height : Double) {
        setWidthCenter(width)
        setHeightCenter(height)
    }
    
    public mutating func setWidthHeight(width: Double, height : Double) {
        self.right = self.left + width
        self.bottom = self.top + height
    }
    
    public func containsXY(x : Float, y : Float) -> Bool {
        return left < Double(x) && Double(x) < right && top < Double(y) && Double(y) < bottom
    }
    
    public func containsXY(x : Double, y : Double) -> Bool {
        return left < x && x < right && top < y && y < bottom
    }
    
    public func containsPoint(point : Point) -> Bool {
        return containsXY(point.getX(), y: point.getY())
    }
    
    public func intersectRect(rect :Rect) -> Bool {
        return rect.containsXY(left, y: top) ||
            rect.containsXY(right, y:  top) ||
            rect.containsXY(left, y: bottom) ||
            rect.containsXY(right, y: bottom) ||
            self.containsXY(rect.left, y: rect.top) ||
            self.containsXY(rect.right, y: rect.top) ||
            self.containsXY(rect.left, y: rect.bottom) ||
            self.containsXY(rect.right, y: rect.bottom)
    }
    
    public func intersecsLine(c1 : Point, c2 : Point) -> Bool {
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
}

public protocol Point {
    func getX() -> Double
    func getY() -> Double
}

public protocol PointMutable : Point {
    mutating func setX(x : Float)
    mutating func setY(y : Float)
    
    mutating func setX(x : Double)
    mutating func setY(y : Double)
    mutating func set(x : Double, y: Double) -> PointMutable
    mutating func set(x : Float, y: Float) -> PointMutable
}

public struct PathUtils {
    public static func isOnPath(points : [Point], rect : Rect) -> Bool {
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
