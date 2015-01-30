//
//  ProjectionController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/28/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreGraphics
import MapKit

// This class tries to put some efficiency into drawing by creating sub projections at the
// next zoomlevel and create the next ones in the backgrond.

class ProjectionController {
    var renderer : MKOverlayRenderer
    var bgQueue : dispatch_queue_t
    var mapInset : MKMapSize
    
    var cgPaths = [String:CGPath]()
    var writeLock : dispatch_queue_t = dispatch_semaphore_create(1)
    
    init(renderer : MKOverlayRenderer) {
        self.renderer = renderer
        bgQueue =  dispatch_queue_create("projections", DISPATCH_QUEUE_CONCURRENT)
        self.mapInset = renderer.mapRectForRect(CGRect(origin: renderer.pointForMapPoint(MKMapPoint(x:0, y: 0)), size: CGSize(width: 33.0/pow(2.0,-21), height: 33/pow(2.0,-21)))).size
    }
    
    var projections : [String:MKMapProjection] = [String:MKMapProjection]()
    
    func getProjectionName(mapRect : MKMapRect, zoomScale : MKZoomScale) -> String {
        let zoomLevel = 22+Int(log(zoomScale))
        let name = "\(Rect(mapRect:mapRect).toString()) - \(zoomLevel)"
        return name
    }
    
    func storeCGPath(journeyPattern : JourneyPattern, cgPath : CGPath) {
        dispatch_semaphore_wait(writeLock, DISPATCH_TIME_FOREVER)
        cgPaths[journeyPattern.id] = cgPath
        dispatch_semaphore_signal(writeLock)
    }

    
    func getProjection(mapRect: MKMapRect, zoomScale : MKZoomScale) -> MKMapProjection {
        let name = getProjectionName(mapRect, zoomScale: zoomScale)
        var projection = projections[name]
        if projection == nil {
            //if BLog.DEBUG { BLog.logger.debug("No Projection \(name)") }
            // Self Registers
            projection = MKMapControlledProjection(controller: self, zoomScale: zoomScale, mapRect: mapRect)
        }
        return projection!
    }
    
    func register(mapProjection : MKMapControlledProjection) {
        // Okay, to save memory we don't save these.
        //projections[mapProjection.name] = mapProjection
    }
    
    // NOT_USED on iPhone. 
    
    // This method gets called by the MKMapControlledProjection to generate a CGPath. However, we find
    // on the iPhone that the The CGPath is the same for every projection. So, we just store a copy for
    // each journeyPattern in the controller instead.
    
    func createPath(projection : MKMapControlledProjection, journeyPattern : JourneyPattern) {
        let mapRect = MKMapRectInset(journeyPattern.getGeoRect().toMapRect(), -mapInset.width, -mapInset.height)
        if !projection.hasCGPath(journeyPattern) && MKMapRectIntersectsRect(mapRect, projection.mapRect) {
            dispatch_async(bgQueue, {
                let timeStart = CACurrentMediaTime()
                if BLog.DEBUG_PATTERN { BLog.logger.debug("started journeyPattern \(journeyPattern.id) for \(Rect(mapRect: projection.mapRect).toString())") }
                projection.internalCreateCGPath(journeyPattern)
                let timeEnd = CACurrentMediaTime()
                if BLog.DEBUG_PATTERN { BLog.logger.debug("finished journeyPattern \(journeyPattern.id) for \(Rect(mapRect: projection.mapRect).toString()) \(timeEnd - timeStart) secs") }
            })
        }
    }
}