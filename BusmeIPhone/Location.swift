//
//  Location.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/10/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class Location {
    var name : String
    var latitude : Double
    var longitude : Double
    var speed : Double
    var bearing : Double
    var time : TimeValue64
    var source : String?
    
    init(name: String, lon : Double, lat : Double) {
        self.name = name
        self.longitude = lon
        self.latitude = lat
        self.speed = 0
        self.bearing = 0
        self.time = UtilsTime.current()
        self.source = "CLLocationManager"
    }
}

class LocationEventData {
    var location : Location
    init(location : Location) {
        self.location = location
    }
}