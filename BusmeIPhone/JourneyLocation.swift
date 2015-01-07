//
//  JourneyLocation.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/7/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation

public class JourneyLocation {
    public var id : String?
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
    
    public func loadParsedXMLTag(tag : Tag) {
        self.id = tag.attributes["id"]
        self.lat = (tag.attributes["lat"]! as NSString).doubleValue
        self.lat = (tag.attributes["lon"]! as NSString).doubleValue
        self.lat = (tag.attributes["direction"]! as NSString).doubleValue
        self.lat = (tag.attributes["distance"]! as NSString).doubleValue
        self.reported = tag.attributes["reported"] == "true"
        self.reported_time = Int64((tag.attributes["reported_time"]! as NSString).integerValue)
        self.recorded_time = Int64((tag.attributes["recorded_time"]! as NSString).integerValue)
        self.onroute = tag.attributes["onroute"] == "true"
    }
}
