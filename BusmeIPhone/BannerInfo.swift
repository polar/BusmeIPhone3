//
//  BannerInfo.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/4/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class BannerInfo : MessageBase, StorageProtocol {
    
    override func isValid() -> Bool {
        return !(id.isEmpty) && title != nil && msgDescription != nil
    }
    
    func preSerialize(api: ApiBase, time: TimeValue64) {

    }
    func postSerialize(api: ApiBase, time: TimeValue64) {

    }
}