//
//  BusmeSiteView.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/15/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import MapKit

class BusmeSiteView : MKOverlayRenderer {
    
    lazy var diagonalDistance = {
        let brect = self.overlay.boundingMapRect
        let se = MKMapPointMake(brect.origin.x + brect.size.width,
            brect.origin.y + brect.size.height)
        let distance = MKMetersBetweenMapPoints(brect.origin, se)
        return distance
    }()
    
    
    func drawSiteGraphic(mapRect : MKMapRect, zoomscale: MKZoomScale, context: CGContextRef) {
        let mpoint = MKMapPointForCoordinate(overlay.coordinate)
        let cgpoint = pointForMapPoint(mpoint)
        let zoomlevel = pow(2,zoomscale)
        let p = MKMapProjection(renderer: self, zoom: Int(zoomlevel), rect: mapRect)
        let cgrect = rectForMapRect(overlay.boundingMapRect)
        CGContextSaveGState(context)
        CGContextSetLineWidth(context, 2.0/zoomscale)
        CGContextSetFillColorWithColor(context, UIColor.purpleColor().colorWithAlphaComponent(0.5).CGColor)
        CGContextSetStrokeColorWithColor(context, UIColor.redColor().colorWithAlphaComponent(0.9).CGColor)
        
        if diagonalDistance > 20*1609*2 {
            CGContextFillRect(context, cgrect)
            CGContextStrokeRect(context, cgrect)
        } else {
            let dist = cgrect.size.height * zoomscale * cgrect.size.height * zoomscale + cgrect.size.width * zoomscale * cgrect.size.width * zoomscale
            let radius = sqrt(dist)
            let mradius = [200.0, [10.0, radius].max].min
            let boxwidth = mradius/zoomscale
            let mrect = CGRect(cgpoint.x - boxwidth/2, cgpoint.y - boxwidth/2, boxwidth, boxwidth)
            CGContextFillEllipseInRect(context, mrect)
            CGContextStrokeEllipseInRect(context, mrect)
        }
    }

}
