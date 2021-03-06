//
//  MarkerInfo.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/4/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation

class MarkerInfo : MessageBase, StorageProtocol {
    
    override init(tag : Tag) {
        super.init(tag : tag)
        if expiryTime == 0 {
            // reading from the web server
            // Markers as of 2015-01-01 do not yet expire, so make them expire 8 years from now.
            // This won't compile!!!
            //let eightYears : Int64 = Int64(8) * Int64(365) * Int64(24) * Int64(60) * Int64(60) * Int64(1000)
            expiryTime = UtilsTime.current() + Int64(8*365*24*60*60) * Int64(1000)
        }
    }
    
    override init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func isValid() -> Bool {
        return title != nil && msgDescription != nil
    }
    
    func preSerialize(api : ApiBase, time : TimeValue64) {
        
    }
    
    func postSerialize(api : ApiBase, time : TimeValue64) {
        
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}