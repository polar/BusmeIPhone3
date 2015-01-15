//
//  Projection.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/9/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreGraphics
import MapKit

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
    
    public func translatePoint(projectedPoint : Point, reuse : PointMutable? = nil) -> PointMutable {
        var out = reuse == nil ? PointImpl() as PointMutable : reuse!
        
        let zoomDifference = MAX_ZOOM_LEVEL - zoomLevel
        
        let div = pow(2.0, Double(zoomDifference))
        let x = Float(projectedPoint.getX()/div + offsetX)
        let y = Float(projectedPoint.getY()/div + offsetX)

        return out.set(x, y: y)
    }
    
    public func fromPixels(x : Double, y : Double) -> GeoPoint {
        return ScreenPathUtils.pixelXYToLatLong(CGFloat(screenRect.left + x + Double(worldSize_2)), pixelY: CGFloat(screenRect.top + y + Double(worldSize_2)), levelOfDetail: zoomLevel)
    }
    
    public func toMapPixels(geoPoint : GeoPoint, reuse : PointMutable? = nil) -> Point {
        var out = reuse == nil ? CGPoint() as PointMutable : reuse!
        ScreenPathUtils.latLongToPixelXY(geoPoint.getLatitude(), longitude: geoPoint.getLongitude(), levelOfDetail: zoomLevel, reuse: out)
        out.setX(out.getX() + offsetX)
        out.setY(out.getY() + offsetY)
        return out
    }
    
}

public class MKMapProjection : Projection {
    public var renderer : MKOverlayRenderer
    
    public init(renderer: MKOverlayRenderer, zoomScale: MKZoomScale, mapRect: MKMapRect) {
        self.renderer = renderer
        let zoom = 22 + Int(log(zoomScale))  // MAX_ZOOM_LEVEL - -log(zoomScale)
        super.init(zoom: zoom, rect: Rect(mapRect: mapRect))
    }
    
    public override func translatePoint(projectedPoint: Point, reuse: PointMutable?) -> PointMutable {
        return renderer.pointForMapPoint(projectedPoint as MKMapPoint)
    }
}