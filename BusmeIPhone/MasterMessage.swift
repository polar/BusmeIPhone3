//
//  MarkerInfo.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/4/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation

public class MasterMessage : MessageBase, StorageProtocol {
    
    public override func isValid() -> Bool {
        return title != nil && content != nil
    }
    
    public func preSerialize(api : ApiBase, time : TimeValue64) {
        
    }
    
    public func postSerialize(api : ApiBase, time : TimeValue64) {
        
    }

}