//
//  MasterMessageStore.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class MasterMessageStore : Storage {
    
    var masterMessages : [String:MasterMessage] = [String:MasterMessage]()
    
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
    
    func encodeWithCoder( coder : NSCoder ) {
        coder.encodeObject(masterMessages, forKey: "masterMessages")
    }
    
    override func preSerialize(api: ApiBase, time: TimeValue64) {
        for masterMessage in masterMessages.values.array {
            masterMessage.preSerialize(api, time: time)
        }
    }
    
    override func postSerialize(api: ApiBase, time: TimeValue64) {
        for masterMessage in masterMessages.values.array {
            masterMessage.postSerialize(api, time: time)
        }
    }
    
    func getMasterMessages() -> [MasterMessage] {
        return masterMessages.values.array
    }
    
    func getMasterMessage(id: String) -> MasterMessage? {
        return masterMessages[id]
    }
    
    func empty() {
        self.masterMessages = [String:MasterMessage]()
    }
    
    func doesContainMasterMessage(id : String) -> Bool {
        return masterMessages[id] != nil
    }
    
    func storeMasterMessage(masterMessage : MasterMessage) {
        masterMessages[masterMessage.id] = masterMessage
    }
    
    func removeMasterMessage(id : String) {
        let masterMessage = masterMessages[id]
        if masterMessage != nil {
            masterMessages[id] = nil
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}