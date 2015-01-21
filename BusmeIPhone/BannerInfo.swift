//
//  BannerInfo.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/4/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class BannerInfo : MessageBase, StorageProtocol {
    
    public override func isValid() -> Bool {
        return !(id.isEmpty) && title != nil && description != nil
    }
    
    public func preSerialize(api: ApiBase, time: TimeValue64) {

    }
    public func postSerialize(api: ApiBase, time: TimeValue64) {

    }
}