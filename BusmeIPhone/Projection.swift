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

class Projection {
    let MAX_ZOOM_LEVEL = 22
    
    var zoomLevel : Int = 0
    var worldSize_2 : Int = 0
    var offsetX : Double = 0
    var offsetY : Double = 0
    
    var screenRect : Rect
    
    init(zoom : Int, rect : Rect) {
        self.zoomLevel = zoom
        self.worldSize_2 = ScreenPathUtils.getMapSize(zoom)
        self.screenRect = rect
    }
    
    func translatePoint(projectedPoint : Point) -> PointMutable {
        var out = PointImpl()
        
        let zoomDifference = MAX_ZOOM_LEVEL - zoomLevel
        
        let div = pow(2.0, Double(zoomDifference))
        let x = Float(projectedPoint.getX()/div + offsetX)
        let y = Float(projectedPoint.getY()/div + offsetX)
        
        return out.set(x, y: y)
    }

    
    func translatePoint(projectedPoint : Point, inout reuse : PointMutable) -> PointMutable {
        var out = reuse
        
        let zoomDifference = MAX_ZOOM_LEVEL - zoomLevel
        
        let div = pow(2.0, Double(zoomDifference))
        let x = Float(projectedPoint.getX()/div + offsetX)
        let y = Float(projectedPoint.getY()/div + offsetX)

        return out.set(x, y: y)
    }
    
    func fromPixels(x : Double, y : Double) -> GeoPoint {
        return ScreenPathUtils.pixelXYToLatLong(CGFloat(screenRect.left + x + Double(worldSize_2)), pixelY: CGFloat(screenRect.top + y + Double(worldSize_2)), levelOfDetail: zoomLevel)
    }
    
    func toMapPixels(geoPoint : GeoPoint, reuse : PointMutable? = nil) -> Point {
        var out = reuse == nil ? CGPoint() as PointMutable : reuse!
        ScreenPathUtils.latLongToPixelXY(geoPoint.getLatitude(), longitude: geoPoint.getLongitude(), levelOfDetail: zoomLevel, reuse: out)
        out.setX(out.getX() + offsetX)
        out.setY(out.getY() + offsetY)
        return out
    }
    
}

class MKMapProjection : Projection {
    unowned var renderer : MKOverlayRenderer
    var zoomScale : MKZoomScale
    var lineWidth : CGFloat
    var mapRect : MKMapRect
    var cgRect : CGRect
    
    // NOT_USED 
    
    var writeLock : dispatch_semaphore_t
    var patternCGPaths : [String:CGPath] = [String:CGPath]()
    
    init(renderer: MKOverlayRenderer, zoomScale: MKZoomScale, mapRect: MKMapRect) {
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
    
    override func translatePoint(projectedPoint: Point) -> PointMutable {
        let cgPoint = renderer.pointForMapPoint(projectedPoint as MKMapPoint)
        return cgPoint
    }
    
    override func translatePoint(projectedPoint: Point, inout reuse: PointMutable) -> PointMutable {
        let cgPoint = renderer.pointForMapPoint(projectedPoint as MKMapPoint)
        reuse.set(Double(cgPoint.x), y: Double(cgPoint.y))
        return cgPoint
    }
    
    // NOT_USED
    
    func storeCGPath(journeyPattern : JourneyPattern, cgPath : CGPath) {
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        patternCGPaths[journeyPattern.id] = cgPath
        dispatch_semaphore_signal(writeLock)
    }
    
    // NOT USED
    
    func hasCGPath(journeyPattern : JourneyPattern) -> Bool {
        return patternCGPaths[journeyPattern.id] != nil
    }
    
    func createCGPath(journeyPattern : JourneyPattern) -> CGPath {
        let projectedPath = journeyPattern.getProjectedPath()
        let path = ScreenPathUtils.toClippedScreenPath(projectedPath, projection: self, path: nil)
        storeCGPath(journeyPattern, cgPath: path.cgpath)
        return path.cgpath
    }
    
    // NOT USED overridden below
    
    func getCGPath(journeyPattern : JourneyPattern) -> CGPath {
        var cgPath = patternCGPaths[journeyPattern.id]
        let hasPath = cgPath != nil
        if !hasPath {
            cgPath = createCGPath(journeyPattern)
        }
        return cgPath!
    }
    
    deinit {
        if BLog.DEALLOC { BLog.logger.debug("DEALLOC \(reflect(self).summary)") }
    }

}

class MKMapControlledProjection : MKMapProjection {
    let name : String!
    unowned var projectionController : ProjectionController
    var upperLeft : MKMapControlledProjection?
    var upperRight : MKMapControlledProjection?
    var lowerLeft : MKMapControlledProjection?
    var lowerRight : MKMapControlledProjection?
    
    init(controller : ProjectionController, zoomScale: MKZoomScale, mapRect: MKMapRect) {
        self.projectionController = controller
        super.init(renderer: controller.renderer, zoomScale: zoomScale, mapRect: mapRect)
        self.name = controller.getProjectionName(mapRect, zoomScale: zoomScale)
        controller.register(self)
    }
    
    // NOT USED

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
    
    
    // NOT USED
    
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
    
    // NOT USED
    
    func internalCreateCGPath(journeyPattern : JourneyPattern) {
        let cgPath = super.createCGPath(journeyPattern)
    }
    
    // NOT USED
    // Called by the controller to create a CGPath. We tried to create CGPaths specific
    // to sub projections in the background. However, it appears that the CPPath is the
    // same regardless of the projection since the CGPath seems to be tied more to the
    // Mercator projection than the actual screen. The Graphics Context will clip the
    // path more efficiently.
    override func createCGPath(journeyPattern: JourneyPattern) -> CGPath {
        let cgPath = super.createCGPath(journeyPattern)
        createSubProjections()
        createPathsForSubProjections(journeyPattern)
        return cgPath
    }
    
    // On the iPhone, the projection doesn't seem to matter. The CGPaths
    // are tied more to the Mercator projection than the actual screen. Therefore,
    // the CGPath is the same for any mapRect. We just let the CGGraphics Context
    // clip the path. So, we store a CGPath for the journeyPattern in a controller
    // hash. We do not pre-create subprojections in order to create clipped paths
    // in the background. We just do it once, and store it. Of course, we should
    // probably clear it if it gets replaced.
    
    override func getCGPath(journeyPattern : JourneyPattern) -> CGPath {
        var cgPath = projectionController.cgPaths[journeyPattern.id]
        let hasPath = cgPath != nil
        if !hasPath {
            let projectedPath = journeyPattern.getProjectedPath()
            // The only thing the projection is used here for is a reference to the renderer.pointForMapPoint()
            let cgPoints = ScreenPathUtils.projectedToScreenPath(projectedPath, projection: self)
            let path = CGPathCreateMutable()
            if cgPoints.count > 1 {
                CGPathMoveToPoint(path, nil, CGFloat(cgPoints[0].getX()), CGFloat(cgPoints[0].getY()))
                for(var i = 1; i < cgPoints.count; i++) {
                    CGPathAddLineToPoint(path, nil, CGFloat(cgPoints[i].getX()), CGFloat(cgPoints[i].getY()))
                }
                projectionController.storeCGPath(journeyPattern, cgPath: path)
            }
            return path
        }
        return cgPath!
    }

    deinit {
        if BLog.DEALLOC { BLog.logger.debug("DEALLOC \(reflect(self).summary)  cgPaths \(projectionController.cgPaths.count)") }
        projectionController.cgPaths = [:]
    }

}