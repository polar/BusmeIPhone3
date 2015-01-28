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
    
    init(renderer : MKOverlayRenderer) {
        self.renderer = renderer
        bgQueue =  dispatch_queue_create("projections", DISPATCH_QUEUE_CONCURRENT)
        self.mapInset = renderer.mapRectForRect(CGRect(origin: renderer.pointForMapPoint(MKMapPoint(x:0, y: 0)), size: CGSize(width: 33.0/pow(2.0,-21), height: 33/pow(2.0,-21)))).size
    }
    
    var projections : [String:MKMapProjection] = [String:MKMapProjection]()
    
    func getProjection(mapRect: MKMapRect, zoomScale : MKZoomScale) -> MKMapProjection {
        let zoomLevel = 22+Int(log(zoomScale))
        let name = "\(Rect(mapRect:mapRect).toString()) - \(zoomLevel)"
        if BLog.DEBUG { BLog.logger.debug("Projection:\(name)") }
        var projection = projections[name]
        if projection == nil {
            // Self Registers
            projection = MKMapControlledProjection(controller: self, zoomScale: zoomScale, mapRect: mapRect)
        }
        return projection!
    }
    
    func register(mapProjection : MKMapControlledProjection) {
        projections[mapProjection.name] = mapProjection
    }
    
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