//
//  BannerInfo.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/4/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

public class BannerInfo {
    public var  id : String = "";
    public var  point : CLLocationCoordinate2D?;

    public var  version : TimeValue64 = 0;
    
    public var  length  : Int = 5 * 1000; // milliseconds
    public var  frequency  : Int = 1 * 60 * 1000; // milliseconds
    public var  radius : Float = 500; // feet?
    public var  priority : Float = 0;
    public var  expiryTime : TimeValue64?;
    public var  title : String = "";
    public var  description : String = "";
    public var  goUrl : String?;
    public var  iconUrl : String?;
    public var  seen : Bool = false;
    public var  lastSeen : TimeValue64?;
    public var  beginSeen : TimeValue64?;
    public var  onDisplayQueue : Bool = false;
    public var  displayed : Bool = false;
    public var  loaded : Bool = false;

    public var propList = [
        "id",
        "point",
        "version", 
        "length", 
        "frequency", 
        "radius", 
        "priority", 
        "expiryTime", 
        "title", 
        "description", 
        "goUrl", 
        "iconUrl", 
        "seen", 
        "lastSeen", 
        "beginSeen", 
        "onDisplayQueue", 
        "displayed", 
        "loaded", 
    ];
    
    func initWithCoder(decoder: NSCoder) -> Void {
        self.id = decoder.decodeObjectForKey("id") as String;
        //self.point = decoder.decodeObjectOfClass(CLLocationCoordinate2D.self, forKey: "point")
        self.version = decoder.decodeInt64ForKey("version")
        self.frequency = Int(decoder.decodeIntForKey("frequency"))
        self.length = Int(decoder.decodeIntForKey("length"))
        self.radius = decoder.decodeFloatForKey("radius")
        self.priority = decoder.decodeFloatForKey("priority")
        self.expiryTime = decoder.decodeInt64ForKey("expiryTime")
        self.title = decoder.decodeObjectForKey("title") as String;
        self.description = decoder.decodeObjectForKey("description") as String
        self.goUrl = decoder.decodeObjectForKey("goUrl") as? String
        self.iconUrl = decoder.decodeObjectForKey("iconUrl") as? String
        self.seen = decoder.decodeBoolForKey("seen")
        self.lastSeen = decoder.decodeInt64ForKey("lastSeen")
        self.beginSeen = decoder.decodeInt64ForKey("beginSeen")
        self.onDisplayQueue = decoder.decodeBoolForKey("onDisplayQueue")
        self.displayed = decoder.decodeBoolForKey("displayed")
        self.loaded = decoder.decodeBoolForKey("loaded")
        self
    }

    public func encodeWithCoder(encoder: NSCoder) -> Void {
        encoder.encodeObject(id, forKey: "id")
        //encoder.encodeObject(point, forKey: "point")
        encoder.encodeInt64(version, forKey: "version")
        encoder.encodeInt(Int32(length), forKey: "length")
        encoder.encodeInt(Int32(frequency), forKey: "frequency")
        encoder.encodeObject(radius, forKey: "radius")
        encoder.encodeObject(priority, forKey: "priority")
        encoder.encodeInt64(expiryTime!, forKey: "expiryTime")
        encoder.encodeObject(title, forKey: "title")
        encoder.encodeObject(description, forKey: "description")
        encoder.encodeObject(goUrl, forKey: "goUrl")
        encoder.encodeObject(iconUrl, forKey: "iconUrl")
        encoder.encodeObject(seen, forKey: "seen")
        if (lastSeen != nil) {
            encoder.encodeInt64(lastSeen!, forKey: "lastSeen")
        }
        if (beginSeen != nil) {
            encoder.encodeInt64(beginSeen!, forKey: "beginSeen")
        }
        encoder.encodeObject(onDisplayQueue, forKey: "onDisplayQueue")
        encoder.encodeObject(displayed, forKey: "displayed")
        encoder.encodeObject(loaded, forKey: "loaded")
    }

    public init() {
        self.seen = false
        self.loaded = false
        self.onDisplayQueue = false
    }

    public func setBeginSeen(time: TimeValue64) -> Void {
        self.seen = true;
        self.beginSeen = time;
    }

    public func shouldBeSeen(time: TimeValue64) -> Bool {
     //!@seen || time < expiryTime && @lastSeen + freque
      return time < expiryTime && (!seen || beginSeen == nil && lastSeen != nil && (lastSeen! + frequency) < time)
    }

    public func onDisplay(time: TimeValue64?) -> Void {
        if (time == nil) {
//            time = UtilsTime.current
        }
        self.beginSeen = time
        self.displayed = true
    }
    
    public func onDismiss(time: TimeValue64?) -> Void {
        if (time == nil) {
//            time = UtilsTime.current
        }
        self.lastSeen = time
        self.beginSeen = nil
        self.displayed = false
    }

    //##
    //# Only a valid call if shouldBeSeen! is true
    //#
    public func nextTime(now : TimeValue64) -> TimeValue64 {
        if (!seen) {
            return now
        } else if (lastSeen != nil) {
            return lastSeen! + frequency;
        } else {
            return now + frequency;
        }
    }
    
    public func setLastSeenNow() -> TimeValue64 {
//        self.lastSeen = Utils::Time.current
        return self.lastSeen!;
    }

    public func isDisplayTimeExpired(time: TimeValue64) -> Bool {
        return (beginSeen != nil) && (beginSeen! + length) < time
    }

    public func loadParsedXML(tag : Tag) -> Void {
        self.id = tag.attributes["id"]!
        self.goUrl = tag.attributes["goUrl"]
        self.iconUrl = tag.attributes["iconUrl"]
        for m in tag.childNodes {
            switch (m.name) {
                case "Title":
                    self.title = m.text!
                    break;
                case "Description":
                    self.description = m.text!
                    break;
            default:
                break;
            }
        }
        self.length =  tag.attributes["length"]!.toInt()!; // .to_f/1000.0
//        self.frequency = tag.attributes["frequency"].to_f/1000.0
//        self.expiryTime = Time.at(tag.attributes["expiryTime"].toInt64()
//        self.priority = tag.attributes["priority"].to_f
//        self.version = tag.attributes["version"]!.toInt()
//        lon = tag.attributes["lon"].to_f
//        lat = tag.attributes["lat"].to_f
//        self.point = Integration::GeoPoint.new(lat * 1E6, lon * 1E6)
//        self.radius = tag.attributes["radius"].to_i
        self.loaded = true
    }
}