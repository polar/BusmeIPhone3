//
//  NameId.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class NameId {
    public var name : String
    public var id : String
    public var route_id : String?
    public var type : String?
    public var version : TimeValue64?;
    public var sched_time_start : TimeValue64?
    public var time_start : TimeValue64?
    
    public init(id: String, name: String) {
        self.name = name
        self.id = id
    }
    
    func initWithCoder(decoder : NSCoder) {
        self.id = decoder.decodeObjectForKey("id")! as String
        self.name = decoder.decodeObjectForKey("name")! as String
        self.route_id = decoder.decodeObjectForKey("route_id") as? String
        self.type = decoder.decodeObjectForKey("type") as? String
        self.version = decoder.decodeInt64ForKey("version")
        self.sched_time_start = decoder.decodeInt64ForKey("sched_time_start")
        self.time_start = decoder.decodeInt64ForKey("time_start")
    }
    
    public func encodeWithCoder(encoder : NSCoder) {
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(name, forKey: "name")
        encoder.encodeObject(route_id, forKey: "route_id")
        encoder.encodeObject(type, forKey: "type")
        
        if (version != nil) {
            encoder.encodeInt64(version!, forKey: "version")
        }
        if (sched_time_start != nil) {
            encoder.encodeInt64(sched_time_start!, forKey: "sched_time_start")
        }
        if (time_start != nil) {
            encoder.encodeInt64(time_start!, forKey: "time_start")
        }
    }
    
    public init(args: [String]) {
        self.name = args[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        self.id = args[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if (args.count > 2) {
            self.type = args[2].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

        }
        if ("R" == type && args.count == 4) {
            self.version = Int64((args[3] as NSString).integerValue) as TimeValue64
        } else if ("V" == type && args.count > 4) {
            self.route_id = args[3].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

            self.version = Int64((args[3] as NSString).integerValue) as TimeValue64
            if (args.count > 5) {
                self.sched_time_start = Int64((args[5] as NSString).integerValue) as TimeValue64
                self.time_start = Int64((args[6] as NSString).integerValue) as TimeValue64
            }
        }
    }
}