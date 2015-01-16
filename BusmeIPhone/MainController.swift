//
//  MainController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

public class MainEventData {
    public var dialog : UIAlertView?
    public var error : HttpStatusLine?
    public var returnStatus : String?
    public var master : Master?
    public var location : GeoPoint?
    public var discoverApi: DiscoverApiVersion1?
    public var masterApi: BuspassApi?
    public var oldController : MasterController?
    public var saveAsDefault : Bool = false
    
    public init() {
        
    }
    
    public init(master : Master) {
        self.master = master
    }
    
    public init(masterApi : BuspassApi, master : Master) {
        self.masterApi = masterApi
        self.master = master
    }
}

public class MainController : BuspassEventListener {
    public var api : DiscoverApiVersion1
    public var discoverController : DiscoverController!
    public var masterController : MasterController?
    public var configurator : Configurator
    
    
    public init(configurator : Configurator, discoverApi : DiscoverApiVersion1) {
        self.configurator = configurator
        self.api = discoverApi
        self.discoverController = DiscoverController(mainController: self)
        api.bgEvents.registerForEvent("Main:init", listener: self)
        api.bgEvents.registerForEvent("Main:Discover:init", listener: self)
        api.bgEvents.registerForEvent("Main:Master:init", listener: self)
    }
    
    public func onBuspassEvent(event: BuspassEvent) {
        let eventName = event.eventName
        let eventData = event.eventData as? MainEventData
        if eventData != nil {
            if (eventName == "Main:init") {
                onInit(eventData!)
            } else if (eventName == "Main:Discover:init") {
                onDiscoverInit(eventData!)
            } else if (eventName == "Main:Master:init") {
                onMasterInit(eventData!)
            }
        }
    }
    
    func onInit(eventData : MainEventData) {
        let (status, api1) = api.get()
        if (api1 == nil) {
            eventData.error = status
            eventData.returnStatus = "Error"
        } else {
            let defaultMaster = configurator.getDefaultMaster()
            if (defaultMaster != nil && defaultMaster!.isValid()) {
                eventData.master = defaultMaster!
                eventData.returnStatus = "Master"
            } else {
                let loc = configurator.getLastLocation()
                if loc != nil {
                    eventData.location = loc!
                }
                eventData.returnStatus = "Discover"
            }
        }
        api.uiEvents.postEvent("Main:Init:return", data: eventData)
    }
    
    func onDiscoverInit(eventData : MainEventData) {
        let oldDiscoverController = discoverController
        self.discoverController = DiscoverController(mainController: self)
        if oldDiscoverController != nil {
            oldDiscoverController.unregisterForEvents()
        }
        eventData.returnStatus = "DiscoverReady"
        api.uiEvents.postEvent("Main:Discover:Init:return", data: eventData)
    }
    
    func onMasterInit(eventData : MainEventData) {
        let oldMasterController : MasterController? = masterController
        if oldMasterController != nil {
            // TODO Posible Error
            oldMasterController!.storeMaster()
        }
        self.masterController = MasterController(api: eventData.masterApi!, master: eventData.master!, mainController: self)
        if oldMasterController != nil {
            oldMasterController!.unregisterForEvents()
        }
        if eventData.saveAsDefault {
            // TODO Possible Error
            configurator.saveAsDefaultMaster(eventData.master!)
        }
        eventData.oldController = oldMasterController
        eventData.returnStatus = "MasterReady"
        api.uiEvents.postEvent("Main:Master:Init:return", data: eventData)
    }
}