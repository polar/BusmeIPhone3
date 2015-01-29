//
//  MarkerInfo.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/4/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation

class MasterMessage : MessageBase {
    
    override func isValid() -> Bool {
        return title != nil && content != nil
    }
    
    func preSerialize(api : ApiBase, time : TimeValue64) {
        
    }
    
    func postSerialize(api : ApiBase, time : TimeValue64) {
        
    }

}