//
//  MasterMessageRequestProcessor.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class MasterMessageRequestProcessor : ArgumentPreparer, ResponseProcessor {
    public var masterMessageBasket : MasterMessageBasket
    
    public init(masterMessageBasket : MasterMessageBasket) {
        self.masterMessageBasket = masterMessageBasket
    }
    
    public func getArguments() -> [String : [String]]? {
        var args = [String:[String]]()
        var ids = [String]()
        var versions = [String]()
        for masterMessage in masterMessageBasket.getMasterMessages() {
            ids.append(masterMessage.getId())
            versions.append("\(masterMessage.version)")
        }
        args["masterMessage_ids[]"] = ids
        args["masterMessage_versions[]"] = versions
        return args
    }
    public func onResponse(response: Tag) {
        var masterMessages = [String : MasterMessage]()
        for child in response.childNodes {
            if child.name.lowercaseString == "masterMessages" {
                for bspec in child.childNodes {
                    if bspec.name.lowercaseString == "masterMessage" {
                        if bspec.attributes["destroy"]? == "1" {
                            let id = bspec.attributes["id"]
                            if id != nil {
                                masterMessages[id!] = nil
                            }
                        } else {
                            let masterMessage = MasterMessage(tag: bspec)
                            if masterMessage.isValid() {
                                masterMessages[masterMessage.getId()] = masterMessage
                            }
                        }
                    }
                }
            }
        }
        for key in masterMessages.keys {
            let masterMessage = masterMessages[key]
            if masterMessage == nil {
                masterMessageBasket.removeMasterMessage(key)
            } else {
                masterMessageBasket.addMasterMessage(masterMessage!)
            }
        }
    }
}