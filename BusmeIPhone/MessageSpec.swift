//
//  MessageSpec.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/4/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class MessageSpec : NSObject {
    var id : String = ""
    var version : TimeValue64 = 0
    var expiryTime : TimeValue64 = 0
    
    override init() {
        super.init()
    }
    
    init(id : String, version: TimeValue64, expiryTime : TimeValue64) {
        self.id = id
        self.version = version
        self.expiryTime = expiryTime
    }
    
    init(coder: NSCoder) {
        self.id = coder.decodeObjectForKey("id") as String;
        self.version = coder.decodeInt64ForKey("version")
        self.expiryTime = coder.decodeInt64ForKey("expiryTime")
    }
    
    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeInt64(version, forKey: "version")
        encoder.encodeInt64(expiryTime, forKey: "expiryTime")
    }
    
    func getId() -> String {
        return id
    }

}