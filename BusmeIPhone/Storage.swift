//
//  Storage.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class Storage : StorageProtocol {
    
    public func preSerialize(api : ApiBase, time : TimeValue64) {
        
    }
    
    public func postSerialize(api : ApiBase, time : TimeValue64) {
        
    }
}

public protocol StorageProtocol {
    func preSerialize(api : ApiBase, time : TimeValue64)
    func postSerialize(api : ApiBase, time : TimeValue64)
}