//
//  MasterMessageStore.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class MasterMessageStore : Storage {
    
    public var masterMessages : [String:MasterMessage] = [String:MasterMessage]()
    
    override init() {
        super.init()
    }
    
    override init( coder : NSCoder) {
        super.init()
        let masterMessages = coder.decodeObjectForKey("masterMessages") as? [String:MasterMessage]
        if masterMessages != nil {
            self.masterMessages = masterMessages!
        }
    }
    
    public func encodeWithCoder( coder : NSCoder ) {
        coder.encodeObject(masterMessages, forKey: "masterMessages")
    }
    
    public override func preSerialize(api: ApiBase, time: TimeValue64) {
        for masterMessage in masterMessages.values.array {
            masterMessage.preSerialize(api, time: time)
        }
    }
    
    public override func postSerialize(api: ApiBase, time: TimeValue64) {
        for masterMessage in masterMessages.values.array {
            masterMessage.postSerialize(api, time: time)
        }
    }
    
    public func getMasterMessages() -> [MasterMessage] {
        return masterMessages.values.array
    }
    
    public func getMasterMessage(id: String) -> MasterMessage? {
        return masterMessages[id]
    }
    
    public func empty() {
        self.masterMessages = [String:MasterMessage]()
    }
    
    public func doesContainMasterMessage(id : String) -> Bool {
        return masterMessages[id] != nil
    }
    
    public func storeMasterMessage(masterMessage : MasterMessage) {
        masterMessages[masterMessage.id] = masterMessage
    }
    
    public func removeMasterMessage(id : String) {
        let masterMessage = masterMessages[id]
        if masterMessage != nil {
            masterMessages[id] = nil
        }
    }
}