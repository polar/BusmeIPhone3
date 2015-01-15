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

class BusmeSite : NSObject, MKOverlay {
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
        let bbox = self.master.bbox!
        let nw = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: bbox.north(), longitude: bbox.west()))
        let se = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: bbox.south(), longitude: bbox.east()))
        let lonDelta = abs(nw.x - se.x)
        let latDelta = abs(nw.y - se.y)
        return MKMapRect(origin: nw, size: MKMapSize(width: lonDelta, height: latDelta))
    }()
    
    func intersectsWithRect(mapRect : MKMapRect) -> Bool {
        return MKMapRectIntersectsRect(boundingMapRect, mapRect)
    }
}