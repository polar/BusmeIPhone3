//
//  BusmeSite.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/15/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

@objc protocol BusmeSite  {
    var myPolygon : MKPolygon { get }
}

class BusmeSiteImpl : NSObject, MKOverlay, BusmeSite {
    var master : Master
    
    init(master : Master) {
        self.master = master
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var myPolygon : MKPolygon = {
        let bbox = self.master.bbox!
        
        let nw = CLLocationCoordinate2D(latitude: bbox.north(), longitude: bbox.west())
        let ne = CLLocationCoordinate2D(latitude: bbox.north(), longitude: bbox.east())
        let se = CLLocationCoordinate2D(latitude: bbox.south(), longitude: bbox.east())
        let sw = CLLocationCoordinate2D(latitude: bbox.south(), longitude: bbox.west())
        var coords = [nw, ne, se, sw]
    
        return MKPolygon(coordinates: &coords, count: coords.count)
    }()
    
    lazy var coordinate : CLLocationCoordinate2D = {
        var rect = Rect(boundingBox: self.master.bbox!)
        var center = rect.center()
        return CLLocationCoordinate2D(latitude: center.getY(), longitude: center.getX())
    }()
    
    lazy var boundingMapRect : MKMapRect = {
        // MKMapRect is lower left oriented.
        let bbox = self.master.bbox!
        let sw = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: bbox.south(), longitude: bbox.west()))
        let ne = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: bbox.north(), longitude: bbox.east()))
        let m1 = MKMapRect(origin: sw, size: MKMapSize(width: 0, height: 0))
        let m2 = MKMapRect(origin: ne, size: MKMapSize(width: 0, height: 0))
        return MKMapRectUnion(m1, m2)
        //let lonDelta = ne.x - sw.x
        //let latDelta = ne.y - sw.y
        //return MKMapRectMake(sw.x, ne.y, lonDelta, latDelta)
        //return MKMapRect(origin: sw, size: MKMapSize(width: lonDelta, height: latDelta))
    }()
    
    func intersectsWithRect(mapRect : MKMapRect) -> Bool {
        return MKMapRectIntersectsRect(boundingMapRect, mapRect)
    }
}