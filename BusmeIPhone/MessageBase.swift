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
    public var radius : Double = 0 // feet
    public var title : String?
    public var msgDescription : String?
    public var goUrl : String?
    public var goLabel : String?
    public var content : String?
    public var iconUrl : String?
    public var priority : Double = 0
    public var displayDuration : Double = 1 * 24 * 60 * 60 * 1000 // milliseconds
    public var remindable : Bool = false
    public var lastSeen : TimeValue64?
    public var seen : Bool = false
    public var remindPeriod : Double = 1 * 24 * 60 * 60 * 1000 // milliseconds
    
    // Transients
    public var displayed : Bool = false
    public var remindTime : TimeValue64 = 0
    public var beginSeen : TimeValue64 = 0
    public var loaded : Bool = false
    
    public func isLoaded() -> Bool {
        return loaded
    }
    
    public func isDisplayed() -> Bool {
        return displayed
    }
    
    public func isSeen() -> Bool {
        return seen;
    }

    public func setRemindTime(time : TimeValue64, forward: Double) {
        self.remindTime = time + Int(forward);
    }
    
    public func resetRemindTime(time : TimeValue64) {
        setRemindTime(time, forward: remindPeriod)
    }
    
    public init(tag : Tag) {
        super.init()
        loadParsedXML(tag)
    }
    
    public init(id : String, version: TimeValue64) {
        let now = UtilsTime.current()
        let then = (now + 1 * 24 * 60 * 60 * 1000) as TimeValue64
        super.init(id: id, version: version, expiryTime: then)
    }
    
    public override init(coder: NSCoder) {
        super.init(coder: coder)
        let hasPoint = coder.decodeBoolForKey("hasPoint")
        if (hasPoint) {
            let lat = coder.decodeDoubleForKey("lat")
            let lon = coder.decodeDoubleForKey("lon")
            self.point = CLLocationCoordinate2DMake(lat, lon)
        }
        self.radius = coder.decodeDoubleForKey("radius")
        self.priority = coder.decodeDoubleForKey("priority")
        self.title = coder.decodeObjectForKey("title") as? String;
        self.msgDescription = coder.decodeObjectForKey("description") as? String
        self.content = coder.decodeObjectForKey("content") as? String
        self.goLabel = coder.decodeObjectForKey("goLabel") as? String
        self.goUrl = coder.decodeObjectForKey("goUrl") as? String
        self.iconUrl = coder.decodeObjectForKey("iconUrl") as? String
        self.seen = coder.decodeBoolForKey("seen")
        self.lastSeen = coder.decodeInt64ForKey("lastSeen")
        self.remindable = coder.decodeBoolForKey("remindable")
        self.remindPeriod = coder.decodeDoubleForKey("remindPeriod")
        self.displayDuration = coder.decodeDoubleForKey("displayDuration")
        self.loaded = true
        self
    }
    
    override public func encodeWithCoder(encoder: NSCoder) -> Void {
        super.encodeWithCoder(encoder)
        if (point != nil) {
            encoder.encodeDouble(point!.latitude, forKey: "lat")
            encoder.encodeDouble(point!.longitude, forKey: "lon")
            encoder.encodeBool(true, forKey: "hasPoint")
        } else {
            encoder.encodeBool(false, forKey: "hasPoint")
        }
        encoder.encodeDouble(radius, forKey: "radius")
        encoder.encodeDouble(priority, forKey: "priority")
        encoder.encodeObject(title, forKey: "title")
        encoder.encodeObject(msgDescription, forKey: "description")
        encoder.encodeObject(content, forKey: "content")
        encoder.encodeObject(goLabel, forKey: "goLabel")
        encoder.encodeObject(goUrl, forKey: "goUrl")
        encoder.encodeObject(iconUrl, forKey: "iconUrl")
        encoder.encodeBool(seen, forKey: "seen")
        if (lastSeen != nil) {
            encoder.encodeInt64(lastSeen!, forKey: "lastSeen")
        }
        encoder.encodeBool(remindable, forKey: "remindable")
        
        encoder.encodeDouble(displayDuration, forKey: "displayDuration")
    }
    
    public func shouldBeSeen() -> Bool {
        return shouldBeSeen(UtilsTime.current())
    }
    
    public func shouldBeSeen(time: TimeValue64) -> Bool {
        let nonExpired : Bool = (time < expiryTime)
        let remindPast : Bool = remindTime < time
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
                return now + Int64(10 * 365 * 24 * 60 * 60) * Int64(1000)
            }
        } else {
            return now + Int64(10 * 365 * 24 * 60 * 60) * Int64(1000)
        }
    }
    
    public func reset(time : TimeValue64 = UtilsTime.current()) {
        self.seen = false
        self.displayed = false
        self.lastSeen = nil
        self.remindTime = 0
    }
    
    public func onDisplay() {
        onDisplay(UtilsTime.current())
    }
    
    public func onDisplay(time : TimeValue64) {
        self.seen = true
        self.beginSeen = time
        self.displayed = true
        self.lastSeen = time
    }
    
    public func onDismiss(remind : Bool) {
        onDismiss(remind, time: UtilsTime.current())
    }
    
    public func onDismiss(remind : Bool, time : TimeValue64) {
        self.displayed = false
        self.lastSeen = time
        self.beginSeen = 0
        if (remind && remindable) {
            self.remindTime = time + Int(remindPeriod)
        }
    }
    
    public func isDisplayTimeExpired() -> Bool {
        return isDisplayTimeExpired(UtilsTime.current())
    }
    
    public func isDisplayTimeExpired(time: TimeValue64) -> Bool {
        return Double(beginSeen) + displayDuration < Double(time)
    }
    
    public func loadParsedXML(tag : Tag) {
        let id = tag.attributes["id"]
        if (id != nil) {
            self.id = id!
        }
        self.goUrl = tag.attributes["go_url"]
        if (goUrl == nil) { self.goUrl = tag.attributes["goUrl"] }
        self.iconUrl = tag.attributes["icon_url"]
        if (iconUrl == nil) { self.iconUrl = tag.attributes["iconUrl"] }
        
        // BannerInfo
        let duration = tag.attributes["length"] as NSString?
        if (duration != nil) {
            self.displayDuration = duration!.doubleValue
        }
        
        // BannerInfo remindable is true by default
        let remindable = tag.attributes["remindable"]
        if (remindable != nil) {
            self.remindable = remindable == "true"
        }
        
        for m in tag.childNodes {
            switch m.name.lowercaseString {
            case "title":
                self.title = m.text!
                break;
            case "content":
                self.content = m.text!
                break;
            case "description":
                self.msgDescription = m.text!
                break;
            case "golabel":
                self.goLabel = m.text!
                break;
            default:
                break;
            }
        }
        
        let expiryTime = tag.attributes["expiryTime"] as NSString?
        if (expiryTime != nil) {
            self.expiryTime = Int64(expiryTime!.integerValue)*1000 as TimeValue64
        }
        
        let priority = tag.attributes["priority"] as NSString?
        if (priority != nil) {
            self.priority = priority!.doubleValue
        }
        
        let remindPeriod = tag.attributes["remindPeriod"] as NSString?
        if (remindPeriod != nil) {
            self.remindPeriod = remindPeriod!.doubleValue
        }
        
        // Banner Info : Frequency is technically remindPeriod
        let frequency = tag.attributes["frequency"] as NSString?
        if (frequency != nil) {
            self.remindPeriod = frequency!.doubleValue
        }
        
        let version = tag.attributes["version"] as NSString?
        if (version != nil) {
            self.version = Int64(version!.integerValue) as TimeValue64
        }
        
        let lon = tag.attributes["lon"] as NSString?
        let lat = tag.attributes["lat"] as NSString?
        if (lat != nil && lon != nil) {
            self.point = CLLocationCoordinate2DMake(lat!.doubleValue, lon!.doubleValue)
        }
        
        let radius = tag.attributes["radius"] as NSString?
        if (radius != nil) {
            self.radius = radius!.doubleValue
        }
        self.loaded = true
    }
    
    public func isValid() -> Bool {
        return loaded && (point != nil) && (version > 0);
    }

}