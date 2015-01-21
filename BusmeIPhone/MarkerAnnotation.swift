//
//  MarkerAnnotation.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/20/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class MarkerAnnotation : NSObject, MKAnnotation {
    var markerInfo : MarkerInfo
    var coordinate : CLLocationCoordinate2D
    var title : String
    var subtitle : String?
    
    init(markerInfo : MarkerInfo) {
        self.markerInfo = markerInfo
        self.coordinate = CLLocationCoordinate2D(latitude: markerInfo.point!.getLatitude(), longitude: markerInfo.point!.getLongitude())
        self.title = markerInfo.title!
        self.subtitle = nil
    }

}