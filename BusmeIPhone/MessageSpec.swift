//
//  MessageSpec.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/4/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class MessageSpec {
    public var id : String
    public var version : TimeValue64
    public var expiryTime : TimeValue64
    
    public init(id : String, version: TimeValue64, expiryTime : TimeValue64) {
        self.id = id
        self.version = version
        self.expiryTime = expiryTime
    }
    
    func initWithCoder(decoder: NSCoder) -> Void {
        self.id = decoder.decodeObjectForKey("id") as String;
        self.version = decoder.decodeInt64ForKey("version")
        self.expiryTime = decoder.decodeInt64ForKey("expiryTime")
    }
    
    public func encodeWithCoder(encoder: NSCoder) -> Void {
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeInt64(version, forKey: "version")
        encoder.encodeInt64(expiryTime, forKey: "expiryTime")
    }

}