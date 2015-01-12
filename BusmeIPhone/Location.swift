//
//  Location.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/10/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class Location {
    public var name : String
    public var latitude : Double
    public var longitude : Double
    public var speed : Double
    public var bearing : Double
    public var time : TimeValue64
    
    public init(name: String, lon : Double, lat : Double) {
        self.name = name
        self.longitude = lon
        self.latitude = lat
        self.speed = 0
        self.bearing = 0
        self.time = UtilsTime.current()
    }
}

public class LocationEventData {
    public var location : Location
    public init(location : Location) {
        self.location = location
    }
}