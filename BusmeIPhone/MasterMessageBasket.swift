//
//  MasterMessageBasket.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class MasterMessageBasket {
    public var masterMessageStore : MasterMessageStore
    weak var masterMessageController : MasterMessagePresentationController?
    
    public init(masterMessageStore : MasterMessageStore) {
        self.masterMessageStore = masterMessageStore
    }
    
    public func getMasterMessages() -> [MasterMessage] {
        return masterMessageStore.getMasterMessages()
    }
    
    public func resetMasterMessages(now : TimeValue64 = UtilsTime.current()) {
        for masterMessage in masterMessageStore.getMasterMessages() {
            masterMessage.reset(time: now)
            masterMessageController?.addMasterMessage(masterMessage)
        }
    }
    
    public func empty() {
        for msg in getMasterMessages() {
            removeMasterMessage(msg)
        }
    }
    
    public func addMasterMessage(masterMessage : MasterMessage) {
        let m = masterMessageStore.getMasterMessage(masterMessage.id)
        if (m != nil) {
            if (m!.version < masterMessage.version) {
                masterMessageStore.removeMasterMessage(masterMessage.id)
                masterMessageController?.addMasterMessage(masterMessage)
                masterMessageStore.storeMasterMessage(masterMessage)
            }
        } else {
            masterMessageStore.storeMasterMessage(masterMessage)
            masterMessageController?.addMasterMessage(masterMessage)
        }
    }
    
    public func removeMasterMessage(masterMessage: MasterMessage) {
        masterMessageStore.removeMasterMessage(masterMessage.id)
        masterMessageController?.removeMasterMessage(masterMessage)
    }
    
    public func removeMasterMessage(id : String) {
        let m = masterMessageStore.getMasterMessage(id)
        if (m != nil) {
            masterMessageStore.removeMasterMessage(m!.id)
            masterMessageController?.removeMasterMessage(m!)
        }
    }
    
    
}