//
//  MessageBase.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation

public class MessageBase : MessageSpec {
    public var point : CLLocationCoordinate2D?
    public var radius : Float = 500 // feet
    public var title : String = ""
    public var description : String = ""
    public var goUrl : String?
    public var goLabel : String?
    public var content : String?
    public var iconUrl : String?
    public var loaded : Bool = false
    public var priority : Float = 0
    
    public var seen : Bool = false
    public var lastSeen : TimeValue64?
    public var displayed : Bool = false
    public var remindable : Bool = false
    public var remindPeriod : Int = 1 * 24 * 60 * 60 * 1000 // milliseconds
    public var remindTime : TimeValue64 = 0
    
    public func isLoaded() -> Bool {
        return loaded
    }
    
    public func isDisplayed() -> Bool {
        return displayed
    }
    
    public func isSeen() -> Bool {
        return seen;
    }

    public func setRemindTime(time : TimeValue64, forward: Int) {
        self.remindTime = time + forward;
    }
    
    public func resetRemindTime(time : TimeValue64) {
        setRemindTime(time, forward: remindPeriod)
    }
    
    public init(id : String, version: TimeValue64) {
        let now = UtilsTime.current()
        let then = (now + 1 * 24 * 60 * 60 * 1000) as TimeValue64
        super.init(id: id, version: version, expiryTime: then)
    }
    
    override func initWithCoder(decoder: NSCoder) -> Void {
        super.initWithCoder(decoder)
        let hasPoint = decoder.decodeBoolForKey("hasPoint")
        if (hasPoint) {
            let lat = decoder.decodeDoubleForKey("lat")
            let lon = decoder.decodeDoubleForKey("lon")
            self.point = CLLocationCoordinate2DMake(lat, lon)
        }
        self.radius = decoder.decodeFloatForKey("radius")
        self.priority = decoder.decodeFloatForKey("priority")
        self.title = decoder.decodeObjectForKey("title") as String;
        self.description = decoder.decodeObjectForKey("description") as String
        self.goLabel = decoder.decodeObjectForKey("goLabel") as? String
        self.goUrl = decoder.decodeObjectForKey("goUrl") as? String
        self.iconUrl = decoder.decodeObjectForKey("iconUrl") as? String
        self.seen = decoder.decodeBoolForKey("seen")
        self.lastSeen = decoder.decodeInt64ForKey("lastSeen")
        self.displayed = decoder.decodeBoolForKey("displayed")
        self.remindable = decoder.decodeBoolForKey("remindable")
        self.remindTime = decoder.decodeInt64ForKey("remindTime")
        self.loaded = decoder.decodeBoolForKey("loaded")
        self
    }
    
    override public func encodeWithCoder(encoder: NSCoder) -> Void {
        encoder.encodeObject(id, forKey: "id")
        if (point != nil) {
            encoder.encodeDouble(point!.latitude, forKey: "lat")
            encoder.encodeDouble(point!.longitude, forKey: "lon")
            encoder.encodeBool(true, forKey: "hasPoint")
        } else {
            encoder.encodeBool(false, forKey: "hasPoint")
        }
        encoder.encodeInt64(version, forKey: "version")
        encoder.encodeFloat(radius, forKey: "radius")
        encoder.encodeFloat(priority, forKey: "priority")
        encoder.encodeInt64(expiryTime, forKey: "expiryTime")
        encoder.encodeObject(title, forKey: "title")
        encoder.encodeObject(description, forKey: "description")
        encoder.encodeObject(goUrl, forKey: "goUrl")
        encoder.encodeObject(iconUrl, forKey: "iconUrl")
        encoder.encodeBool(seen, forKey: "seen")
        if (lastSeen != nil) {
            encoder.encodeInt64(lastSeen!, forKey: "lastSeen")
        }
        encoder.encodeBool(remindable, forKey: "remindable")
        
        encoder.encodeBool(displayed, forKey: "displayed")
        encoder.encodeBool(loaded, forKey: "loaded")
    }
    
    public func shouldBeSeen(time: TimeValue64?) -> Bool {
        var now = time == nil ? UtilsTime.current() : time
        
        let nonExpired = (now < expiryTime)
        let remindPast = remindTime < now
        return nonExpired && (!seen || (displayed || (remindable && remindPast)))
    }
    
    // This method is used for sorting. Basically if it is not seen or expired the time is
    // is basically high, so that it will come up at the end of the list and be
    // disposed of by the controller. If it has a later remindTime that will be sorted
    // appropriately.
    public func nextTime(time : TimeValue64?) -> TimeValue64 {
        
        var now = time == nil ? UtilsTime.current() : time!
        if (now < expiryTime) {
            if (remindable) {
                return remindTime
            } else {
                return now + (10 * 365 * 24 * 60 * 60 * 1000)
            }
        } else {
            return now + (10 * 365 * 24 * 60 * 60 * 1000)
        }
    }
    
    public func reset(time : TimeValue64?) {
        self.seen = false
        self.displayed = false
        self.lastSeen = nil
        self.remindTime = 0
    }
    
    public func onDisplay(time : TimeValue64?) {
        self.seen = true
        self.displayed = true
        self.lastSeen = time
    }
    
    public func onDismiss(remind : Bool, time : TimeValue64) {
        self.displayed = false
        self.lastSeen = time
        if (remind && remindable) {
            self.remindTime = time + remindPeriod
        }
    }
    
    public func loadParsedXML(tag : Tag) {
        self.id = tag.attributes["id"]!
        self.goUrl = tag.attributes["go_url"]
        self.iconUrl = tag.attributes["icon_url"]
        self.remindable = "true" == tag.attributes["remindable"]
        for m in tag.childNodes {
            switch m.name {
            case "Title":
                self.title = m.text!
                break;
            case "Content":
                self.content = m.text!
                break;
            case "GoLabel":
                self.goLabel = m.text!
                break;
            default:
                break;
            }
        }
        self.expiryTime = Int64((tag.attributes["expiryTime"]! as NSString).integerValue) as TimeValue64
        
        let priority = tag.attributes["priority"] as NSString?
        if (priority != nil) {
            self.priority = priority!.floatValue
        }
        
        let remindPeriod = tag.attributes["remindPeriod"] as NSString?
        if (remindPeriod != nil) {
            self.remindPeriod = remindPeriod!.integerValue
        }
        self.version = Int64((tag.attributes["version"]! as NSString).integerValue) as TimeValue64
        
        let lon = (tag.attributes["lon"]! as NSString).doubleValue
        let lat = (tag.attributes["lat"]! as NSString).doubleValue
        self.point = CLLocationCoordinate2DMake(lat, lon)
        
        let radius = tag.attributes["radius"] as NSString?
        if (radius != nil) {
            self.radius = radius!.floatValue
        }
        self.loaded = true
    }

}