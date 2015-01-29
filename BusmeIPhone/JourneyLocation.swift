//
//  JourneyLocation.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/7/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation

class PostLocation {
    var journey : Route
    var location : Location
    
    init(journey:Route, location : Location) {
        self.journey = journey
        self.location = location
    }
}

class JourneyLocation : GeoPoint {
    var routeId : String?
    var lat : Double = 0
    var lon : Double = 0
    var dir : Double = 0
    var reported_time : TimeValue64 = 0
    var recorded_time : TimeValue64 = 0
    var timediff : Double = 0
    var onroute : Bool = false
    var reported : Bool = false
    var distance : Double = 0
    var time : Double = -1

    init(tag: Tag) {
        loadParsedXMLTag(tag)
    }
    
    // GeoPoint Protocol 
    func getLatitude() -> Double {
        return lat
    }
    func getLongitude() -> Double {
        return lon
    }
    func getX() -> Double {
        return lon
    }
    func getY() -> Double {
        return lat
    }
    func loadParsedXMLTag(tag : Tag) {
        self.routeId = tag.attributes["id"]
        self.lat = (tag.attributes["lat"]! as NSString).doubleValue
        self.lon = (tag.attributes["lon"]! as NSString).doubleValue
        self.dir = (tag.attributes["direction"]! as NSString).doubleValue
        self.distance = (tag.attributes["distance"]! as NSString).doubleValue
        self.reported = tag.attributes["reported"] == "true"
        self.reported_time = Int64((tag.attributes["reported_time"]! as NSString).integerValue)
        self.recorded_time = Int64((tag.attributes["recorded_time"]! as NSString).integerValue)
        self.onroute = tag.attributes["onroute"] == "true"
    }
    
    func isValid() -> Bool {
        return routeId != nil
    }
    
    func getRouteId() -> String {
        return routeId!
    }
}
