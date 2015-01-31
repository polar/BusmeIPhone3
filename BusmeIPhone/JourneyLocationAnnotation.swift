//
//  JourneyLocationAnnotation.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/20/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class JourneyLocationAnnotation : NSObject, MKAnnotation {
    var journeyLocation : JourneyLocation
    var journeyDisplay : JourneyDisplay
    var coordinate : CLLocationCoordinate2D
    var title : String
    var subtitle : String?
    
    init(journeyDisplay : JourneyDisplay, journeyLocation : JourneyLocation) {
        self.journeyLocation = journeyLocation
        self.journeyDisplay = journeyDisplay
        self.coordinate = CLLocationCoordinate2D(latitude: journeyLocation.lat, longitude: journeyLocation.lon)
        self.title = journeyDisplay.route.code!
        self.subtitle = journeyDisplay.route.name
    }
    
}