//
//  MasterMessageBasket.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class MasterMessageBasket {
    var masterMessageStore : MasterMessageStore
    weak var masterMessageController : MasterMessagePresentationController?
    
    init(masterMessageStore : MasterMessageStore) {
        self.masterMessageStore = masterMessageStore
    }
    
    func getMasterMessages() -> [MasterMessage] {
        return masterMessageStore.getMasterMessages()
    }
    
    func resetMasterMessages(now : TimeValue64 = UtilsTime.current()) {
        for masterMessage in masterMessageStore.getMasterMessages() {
            masterMessage.reset(time: now)
            masterMessageController?.addMasterMessage(masterMessage)
        }
    }
    
    func empty() {
        for msg in getMasterMessages() {
            removeMasterMessage(msg)
        }
    }
    
    func addMasterMessage(masterMessage : MasterMessage) {
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
    
    func removeMasterMessage(masterMessage: MasterMessage) {
        masterMessageStore.removeMasterMessage(masterMessage.id)
        masterMessageController?.removeMasterMessage(masterMessage)
    }
    
    func removeMasterMessage(id : String) {
        let m = masterMessageStore.getMasterMessage(id)
        if (m != nil) {
            masterMessageStore.removeMasterMessage(m!.id)
            masterMessageController?.removeMasterMessage(m!)
        }
    }
    
    
}