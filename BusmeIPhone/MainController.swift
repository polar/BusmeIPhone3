//
//  MainController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

class MainEventData {
    var dialog : UIAlertView?
    var error : HttpStatusLine?
    var returnStatus : String?
    var master : Master?
    var location : GeoPoint?
    var discoverApi: DiscoverApiVersion1?
    var masterApi: BuspassApi?
    var discoverController : DiscoverController?
    var masterController : MasterController?
    var oldMasterController : MasterController?
    var oldDiscoverController : DiscoverController?
    var saveAsDefault : Bool = false
    var forceDiscover : Bool = false
    
    init() {
        
    }
    
    init(forceDiscover: Bool) {
        self.forceDiscover = forceDiscover
    }
    
    init(discoverApi : DiscoverApiVersion1) {
        self.discoverApi = discoverApi
    }
    
    init(master : Master) {
        self.master = master
    }
    
    init(masterApi : BuspassApi, master : Master) {
        self.masterApi = masterApi
        self.master = master
    }
}

class MainController : BuspassEventListener {
    var api : MainApi
    var discoverController : DiscoverController!
    var masterController : MasterController?
    var configurator : Configurator
    
    
    init(configurator : Configurator, api : MainApi) {
        self.configurator = configurator
        self.api = api
        api.bgEvents.registerForEvent("Main:init", listener: self)
        api.bgEvents.registerForEvent("Main:Discover:init", listener: self)
        api.bgEvents.registerForEvent("Main:Master:init", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
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
        let evd = MainEventData()
        evd.dialog = eventData.dialog
        if eventData.forceDiscover {
            let (status, discoverApi) = api.get()
            if (discoverApi != nil) {
                evd.discoverApi = discoverApi
                let loc = configurator.getLastLocation()
                if loc != nil {
                    evd.location = loc!
                }
                evd.returnStatus = "Discover"
            } else {
                evd.returnStatus = "Error"
                evd.error = status
            }
        } else {
            let defaultMaster = configurator.getDefaultMaster()
            if (defaultMaster != nil && defaultMaster!.isValid()) {
                evd.master = defaultMaster!
                evd.returnStatus = "Master"
            } else {
                let (status, discoverApi) = api.get()
                if discoverApi != nil {
                    evd.discoverApi = discoverApi
                    let loc = configurator.getLastLocation()
                    if loc != nil {
                        evd.location = loc!
                    }
                    evd.returnStatus = "Discover"
                } else {
                    evd.returnStatus = "Error"
                    evd.error = status
                }
            }
        }
        api.uiEvents.postEvent("Main:Init:return", data: evd)
    }
    
    func onDiscoverInit(eventData : MainEventData) {
        let evd = MainEventData()
        evd.dialog = eventData.dialog
        let oldDiscoverController = discoverController
        self.discoverController = DiscoverController(api: eventData.discoverApi!)
        if oldDiscoverController != nil {
            oldDiscoverController.unregisterForEvents()
        }
        evd.discoverApi = eventData.discoverApi
        evd.discoverController = discoverController
        evd.oldDiscoverController = oldDiscoverController
        evd.returnStatus = "DiscoverReady"
        api.uiEvents.postEvent("Main:Discover:Init:return", data: evd)
    }
    
    func onMasterInit(eventData : MainEventData) {
        let evd = MainEventData()
        evd.dialog = eventData.dialog
        let oldMasterController : MasterController? = masterController
        if oldMasterController != nil {
            // TODO Posible Error
            oldMasterController!.storeMaster()
            // TODO: We have to deserialize again to get rid of memory cycles with the Journey/Api.
        }
        self.masterController = MasterController(api: eventData.masterApi!, master: eventData.master!, mainController: self)
        if oldMasterController != nil {
            oldMasterController!.unregisterForEventsAllComponents()
        }
        if configurator.getDefaultMaster() == nil || eventData.saveAsDefault {
            // TODO Possible Error
            configurator.saveAsDefaultMaster(eventData.master!)
        }
        evd.masterController = masterController
        evd.oldMasterController = oldMasterController
        evd.returnStatus = "MasterInitialized"
        api.uiEvents.postEvent("Main:Master:Init:return", data: evd)
    }
}