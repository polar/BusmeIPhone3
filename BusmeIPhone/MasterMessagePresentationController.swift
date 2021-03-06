//
//  MasterMessagePresentationController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class MasterMessageComparator : Comparator {
    func compare(lhs: AnyObject, rhs: AnyObject) -> Int {
        return compare(lhs as MasterMessage, b2: rhs as MasterMessage)
    }
    
    func compare(b1 : MasterMessage, b2: MasterMessage) -> Int {
        let now = UtilsTime.current()
        let time = cmp(b1.nextTime(now), b2.nextTime(now))
        if time == 0 {
            return cmp(b1.priority, b2.priority)
        } else {
            return time
        }
    }
}

class MasterMessagePresentationController {
    unowned var api : BuspassApi
    unowned var masterMessageBasket : MasterMessageBasket
    var currentMasterMessage : MasterMessage?
    var masterMessageQ : PriorityQueue<MasterMessage>!
    
    init(api : BuspassApi, basket: MasterMessageBasket) {
        self.api = api
        self.masterMessageBasket = basket
        self.masterMessageQ = PriorityQueue<MasterMessage>(compare: MasterMessageComparator())
    }
    
    func addMasterMessage(masterMessage: MasterMessage) {
        if (!masterMessageQ.doesInclude(masterMessage)) {
            masterMessageQ.push(masterMessage)
        }
    }
    
    func removeMasterMessage(masterMessage: MasterMessage) {
        if (currentMasterMessage === masterMessage) {
            abandonMasterMessage(masterMessage)
        }
        masterMessageQ.delete(masterMessage)
    }
    
    func doesContain(masterMessage: MasterMessage) -> Bool {
        return masterMessageQ.doesInclude(masterMessage)
    }
    
    func onDismiss(remind: Bool, masterMessage : MasterMessage, time: TimeValue64) {
        if currentMasterMessage != nil {
            if currentMasterMessage === masterMessage {
                currentMasterMessage = nil
                masterMessage.onDismiss(remind, time: time)
            } else {
                if BLog.WARN { BLog.logger.warn("Master Message \(masterMessage.title) is not same as current \(currentMasterMessage!.title)") }
                masterMessage.onDismiss(remind, time: time)
            }
        } else {
            if BLog.WARN { BLog.logger.warn("No Current Master Message dismiss \(masterMessage.title) ") }
            masterMessage.onDismiss(remind, time: time)
        }
    }
    
    func roll(removeCurrent : Bool, now : TimeValue64 = UtilsTime.current()) {
        if (currentMasterMessage != nil) {
            if (!removeCurrent && !currentMasterMessage!.isDisplayTimeExpired(now)) {
                return
            } else {
                abandonMasterMessage(currentMasterMessage!)
                currentMasterMessage!.onDismiss(true, time: now)
                masterMessageQ.delete(currentMasterMessage!)
                self.currentMasterMessage = nil
            }
        }
        var masterMessage = masterMessageQ.poll()
        while masterMessage != nil {
            if masterMessage!.shouldBeSeen(now) {
                presentMasterMessage(masterMessage!)
                masterMessage!.onDisplay(now)
                self.currentMasterMessage = masterMessage
                return
            }
            masterMessage = masterMessageQ.poll()
        }
    }
    
    
    func abandonMasterMessage(masterMessage: MasterMessage) {
        let evd = MasterMessageEventData(masterMessage: masterMessage)
        evd.state = MasterMessageEvent.S_DONE
        api.uiEvents.postEvent("MasterMessagePresent:dismiss", data: evd)
    }
    
    func presentMasterMessage(masterMessage: MasterMessage) {
        let evd = MasterMessageEventData(masterMessage: masterMessage)
        api.uiEvents.postEvent("MasterMessagePresent:display", data: evd)
    }
    
    
    func onLocationUpdate(location: GeoPoint, now: TimeValue64 = UtilsTime.current()) {
        for masterMessage in masterMessageBasket.getMasterMessages() {
            if (masterMessage.point == nil ||
                GeoCalc.getGeoAngle(location, c2: masterMessage.point!) < masterMessage.radius) {
                    if masterMessage.shouldBeSeen(now) {
                        masterMessageQ.push(masterMessage)
                    }
            }
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}