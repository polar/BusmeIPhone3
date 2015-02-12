//
//  MasterOverlay.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/23/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class MasterOverlay : NSObject, MKOverlay {
    unowned var masterController : MasterController
    var master : Master
    var coordinate : CLLocationCoordinate2D
    var boundingMapRect : MKMapRect
    
    init(master : Master, masterController : MasterController) {
        self.masterController = masterController
        self.master = master
        self.coordinate =  CLLocationCoordinate2D(latitude: master.lat!, longitude: master.lon!)
        
        let nw = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: master.bbox!.north(), longitude: master.bbox!.west()))
        let se = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: master.bbox!.south(), longitude: master.bbox!.east()))
        let lonDelta = abs(nw.x - se.x)
        let latDelta = abs(nw.y - se.y)
        self.boundingMapRect = MKMapRect(origin: nw, size: MKMapSize(width: lonDelta, height: latDelta))
        
        super.init()

    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC MasterOverlay \(master.slug!)") }
    }

}