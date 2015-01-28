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
    
    public func translatePoint(projectedPoint : Point) -> PointMutable {
        var out = PointImpl()
        
        let zoomDifference = MAX_ZOOM_LEVEL - zoomLevel
        
        let div = pow(2.0, Double(zoomDifference))
        let x = Float(projectedPoint.getX()/div + offsetX)
        let y = Float(projectedPoint.getY()/div + offsetX)
        
        return out.set(x, y: y)
    }

    
    public func translatePoint(projectedPoint : Point, inout reuse : PointMutable) -> PointMutable {
        var out = reuse
        
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
    public var zoomScale : MKZoomScale
    public var lineWidth : CGFloat
    public var mapRect : MKMapRect
    public var cgRect : CGRect
    var writeLock : dispatch_semaphore_t
    
    var patternCGPaths : [String:CGPath] = [String:CGPath]()
    
    public init(renderer: MKOverlayRenderer, zoomScale: MKZoomScale, mapRect: MKMapRect) {
        self.renderer = renderer
        self.zoomScale = zoomScale
        let zoom = 22 + Int(log(zoomScale))  // MAX_ZOOM_LEVEL - -log(zoomScale)
        self.lineWidth = MKRoadWidthAtZoomScale(zoomScale)
        self.mapRect = mapRect
        self.cgRect = renderer.rectForMapRect(mapRect)
        self.cgRect.inset(dx: -lineWidth, dy: -lineWidth)
        self.writeLock = dispatch_semaphore_create(1)
        super.init(zoom: zoom, rect: Rect(cgRect: cgRect))
    }
    
    public override func translatePoint(projectedPoint: Point) -> PointMutable {
        let cgPoint = renderer.pointForMapPoint(projectedPoint as MKMapPoint)
        return cgPoint
    }
    
    public override func translatePoint(projectedPoint: Point, inout reuse: PointMutable) -> PointMutable {
        let cgPoint = renderer.pointForMapPoint(projectedPoint as MKMapPoint)
        reuse.set(Double(cgPoint.x), y: Double(cgPoint.y))
        return cgPoint
    }
    
    public func storeCGPath(journeyPattern : JourneyPattern, cgPath : CGPath) {
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        patternCGPaths[journeyPattern.id] = cgPath
        dispatch_semaphore_signal(writeLock)
    }
    
    func hasCGPath(journeyPattern : JourneyPattern) -> Bool {
        return patternCGPaths[journeyPattern.id] != nil
    }
    
    func createCGPath(journeyPattern : JourneyPattern) -> CGPath {
        let projectedPath = journeyPattern.getProjectedPath()
        let path = ScreenPathUtils.toClippedScreenPath(projectedPath, projection: self, path: nil)
        storeCGPath(journeyPattern, cgPath: path.cgpath)
        return path.cgpath
    }
    
    public func getCGPath(journeyPattern : JourneyPattern) -> CGPath {
        var cgPath = patternCGPaths[journeyPattern.id]
        let hasPath = cgPath != nil
        if !hasPath {
            cgPath = createCGPath(journeyPattern)
        }
        return cgPath!
    }
}

class MKMapControlledProjection : MKMapProjection {
    let name : String!
    var projectionController : ProjectionController
    var upperLeft : MKMapControlledProjection?
    var upperRight : MKMapControlledProjection?
    var lowerLeft : MKMapControlledProjection?
    var lowerRight : MKMapControlledProjection?
    init(controller : ProjectionController, zoomScale: MKZoomScale, mapRect: MKMapRect) {
        self.projectionController = controller
        super.init(renderer: controller.renderer, zoomScale: zoomScale, mapRect: mapRect)
        self.name = "\(Rect(mapRect: mapRect).toString()) - \(zoomLevel)"
        
        controller.register(self)
    }

    func createSubProjections() {
        if zoomLevel > 2 && upperLeft == nil {
            upperLeft = MKMapControlledProjection(controller: projectionController, zoomScale: zoomScale*2, mapRect: mapRect.upperLeftQuadrant())
            
            upperRight = MKMapControlledProjection(controller: projectionController, zoomScale: zoomScale*2, mapRect: mapRect.upperRightQuadrant())
            
            lowerLeft = MKMapControlledProjection(controller: projectionController, zoomScale: zoomScale*2, mapRect: mapRect.lowerLeftQuadrant())
            
            lowerRight = MKMapControlledProjection(controller: projectionController, zoomScale: zoomScale*2, mapRect: mapRect.lowerRightQuadrant())
            
            projectionController.register(upperRight!)
            projectionController.register(upperLeft!)
            projectionController.register(lowerRight!)
            projectionController.register(lowerLeft!)
        }
    }
    
    func createPathsForSubProjections(journeyPattern : JourneyPattern) {
        if upperLeft != nil {
            projectionController.createPath(upperLeft!, journeyPattern: journeyPattern)
        }
        
        if lowerLeft != nil {
            projectionController.createPath(lowerLeft!, journeyPattern: journeyPattern)
        }
        
        if upperRight != nil {
            projectionController.createPath(upperRight!, journeyPattern: journeyPattern)
        }
        
        if lowerRight != nil {
            projectionController.createPath(lowerRight!, journeyPattern: journeyPattern)
        }
    }
    
    func internalCreateCGPath(journeyPattern : JourneyPattern) {
        let cgPath = super.createCGPath(journeyPattern)
    }
    
    override func createCGPath(journeyPattern: JourneyPattern) -> CGPath {
        let cgPath = super.createCGPath(journeyPattern)
        createSubProjections()
        createPathsForSubProjections(journeyPattern)
        return cgPath
    }
}