//
//  Storage.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class Storage : NSObject, StorageProtocol {
    
    override init() {
        super.init()
    }
    
    init(coder : NSCoder) {
        super.init()
        initWithCoder(coder)
    }

    func initWithCoder(coder : NSCoder) {}
    
    func preSerialize(api : ApiBase, time : TimeValue64) {
        
    }
    
    func postSerialize(api : ApiBase, time : TimeValue64) {
        
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}

protocol StorageProtocol : class  {
    func preSerialize(api : ApiBase, time : TimeValue64)
    func postSerialize(api : ApiBase, time : TimeValue64)
}