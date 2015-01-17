//
//  MasterMessagePresentationController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class MasterMessagePresentationController {
    public var api : BuspassApi
    public var masterMessageBasket : MasterMessageBasket
    public var currentMasterMessage : MasterMessage?
    public var masterMessageQ : PriorityQueue<MasterMessage>!
    
    public init(api : BuspassApi, basket: MasterMessageBasket) {
        self.api = api
        self.masterMessageBasket = basket
        self.masterMessageQ = PriorityQueue<MasterMessage>(compare: self.compare)
    }
    
    public func addMasterMessage(masterMessage: MasterMessage) {
        if (!masterMessageQ.doesInclude(masterMessage)) {
            masterMessageQ.push(masterMessage)
        }
    }
    
    public func removeMasterMessage(masterMessage: MasterMessage) {
        if (currentMasterMessage === masterMessage) {
            abandonMasterMessage(masterMessage)
        }
        masterMessageQ.delete(masterMessage)
    }
    
    public func doesContain(masterMessage: MasterMessage) -> Bool {
        return masterMessageQ.doesInclude(masterMessage)
    }
    
    public func roll(removeCurrent : Bool, now : TimeValue64 = UtilsTime.current()) {
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
        var masterMessage = masterMessageQ!.poll()
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
        api.uiEvents.postEvent("MasterMessagePresent:dismiss", data: evd)
    }
    
    func presentMasterMessage(masterMessage: MasterMessage) {
        let evd = MasterMessageEventData(masterMessage: masterMessage)
        api.uiEvents.postEvent("MasterMessagePresent:display", data: evd)
    }
    
    
    public func onLocationUpdate(location: GeoPoint, now: TimeValue64 = UtilsTime.current()) {
        for masterMessage in masterMessageBasket.getMasterMessages() {
            if (masterMessage.point == nil ||
                GeoCalc.getGeoAngle(location, c2: masterMessage.point!) < masterMessage.radius) {
                    if masterMessage.shouldBeSeen(now) {
                        masterMessageQ.push(masterMessage)
                    }
            }
        }
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