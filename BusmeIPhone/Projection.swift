//
//  Projection.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/9/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreGraphics

public class Projection {
    let MAX_ZOOM_LEVEL = 22
    
    public var zoomLevel : Int = 0
    public var worldSize_2 : Int = 0
    public var offsetX : Double = 0
    public var offsetY : Double = 0
    
    public var screenRect : Rect
    public init(zoom : Int, rect : Rect) {
        self.zoomLevel = zoom
        self.worldSize_2 = ScreenPathUtils.getMapSize(zoom)
        self.screenRect = rect
    }
    
    public func translatePoint(point : CGPoint, reuse : CGPoint? = nil) -> CGPoint {
        var out = reuse == nil ? CGPoint() : reuse!
        
        let zoomDifference = MAX_ZOOM_LEVEL - zoomLevel
        
        out.x = CGFloat(Double(Int(point.x) >> zoomDifference) + offsetX)
        out.y = CGFloat(Double(Int(point.y) >> zoomDifference) + offsetY)
        return out
    }
    
    public func fromPixels(x : Double, y : Double) -> GeoPoint {
        return ScreenPathUtils.pixelXYToLatLong(CGFloat(screenRect.left + x + Double(worldSize_2)), pixelY: CGFloat(screenRect.top + y + Double(worldSize_2)), levelOfDetail: zoomLevel)
    }
    
    public func toMapPixels(geoPoint : GeoPoint, reuse : CGPoint? = nil) -> CGPoint {
        var out = reuse == nil ? CGPoint() : reuse!
        ScreenPathUtils.latLongToPixelXY(geoPoint.getLatitude(), longitude: geoPoint.getLongitude(), levelOfDetail: zoomLevel, reuse: out)
        out.x += CGFloat(offsetX)
        out.y += CGFloat(offsetY)
        return out
    }
    
}