//
//  JourneyLocation.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/7/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation

public class PostLocation {
    public var journey : Route
    public var location : Location
    
    public init(journey:Route, location : Location) {
        self.journey = journey
        self.location = location
    }
}

public class JourneyLocation : GeoPoint {
    public var routeId : String?
    public var lat : Double = 0
    public var lon : Double = 0
    public var dir : Double = 0
    public var reported_time : TimeValue64 = 0
    public var recorded_time : TimeValue64 = 0
    public var timediff : Double = 0
    public var onroute : Bool = false
    public var reported : Bool = false
    public var distance : Double = 0
    public var time : Double = -1

    public init(tag: Tag) {
        loadParsedXMLTag(tag)
    }
    
    // GeoPoint Protocol 
    public func getLatitude() -> Double {
        return lat
    }
    public func getLongitude() -> Double {
        return lon
    }
    public func getX() -> Double {
        return lon
    }
    public func getY() -> Double {
        return lat
    }
    public func loadParsedXMLTag(tag : Tag) {
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
    
    public func isValid() -> Bool {
        return routeId != nil
    }
    
    public func getRouteId() -> String {
        return routeId!
    }
}
