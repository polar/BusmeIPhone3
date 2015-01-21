//
//  MasterController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/10/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

class MasterEventData {
    var dialog : UIAlertView?
    var error : HttpStatusLine?
    var returnStatus : String?
    var getTries : Int = 0
    init(dialog : UIAlertView) {
        self.dialog = dialog
    }
    init() {
        
    }
}

public class MasterController : BuspassEventListener {
    public var api : BuspassApi
    public var master : Master
    public var mainController : MainController?
    
    public var directory : String?
    public var bannerBasket : BannerBasket
    public var bannerPresentationController : BannerPresentationController
    public var bannerStore : BannerStore
    
    public var journeyBasket : JourneyBasket
    public var journeyDisplayController : JourneyDisplayController
    public var journeyStore : JourneyStore
    public var journeyVisibilityController : JourneyVisibilityController
    public var journeyDisplaySelectionController : JourneyDisplaySelectionController
    
    public var markerBasket : MarkerBasket
    public var markerPresentationController : MarkerPresentationController
    public var markerStore : MarkerStore
    
    public var masterMessageBasket : MasterMessageBasket
    public var masterMessagePresentationController : MasterMessagePresentationController
    public var masterMessageStore : MasterMessageStore
    
    public var loginForeground : LoginForeground
    public var loginBackground : LoginBackground
    
    public var journeyLocationPoster : JourneyLocationPoster
    public var journeyEventController : JourneyEventController
    public var journeyPostingController : JourneyPostingController
    
    public var updateRemoteInvocation : UpdateRemoteInvocation
    public var journeySyncRemoteInvocation : JourneySyncRemoteInvocation
    
    
    
    public init(api : BuspassApi, master: Master, mainController : MainController?) {
        self.api = api
        self.master = master
        self.mainController = mainController
        
        self.bannerStore = BannerStore()
        self.bannerBasket = BannerBasket(bannerStore: bannerStore)
        self.bannerPresentationController = BannerPresentationController(api: api, basket: bannerBasket)
        
        self.markerStore = MarkerStore()
        self.markerBasket = MarkerBasket(markerStore: markerStore)
        self.markerPresentationController = MarkerPresentationController(api: api, markerBasket: markerBasket)
        
        self.masterMessageStore = MasterMessageStore()
        self.masterMessageBasket = MasterMessageBasket(masterMessageStore: masterMessageStore)
        self.masterMessagePresentationController = MasterMessagePresentationController(api: api, basket: masterMessageBasket)
        
        self.journeyStore = JourneyStore()
        self.journeyBasket = JourneyBasket(api: api, journeyStore: journeyStore)
        self.journeyDisplayController = JourneyDisplayController(api: api, basket: journeyBasket)
        self.journeyVisibilityController = JourneyVisibilityController(api: api, controller: journeyDisplayController)
        self.journeyDisplaySelectionController = JourneyDisplaySelectionController(api : api, journeyDisplayController: journeyDisplayController)
        self.journeyLocationPoster = JourneyLocationPoster(api: api)
        self.journeyEventController = JourneyEventController(api: api)
        self.journeyPostingController = JourneyPostingController(api: api)
        
        self.loginForeground = LoginForeground(api: api)
        self.loginBackground = LoginBackground(api: api)
        
        self.updateRemoteInvocation = UpdateRemoteInvocation(api: api, bannerBasket: bannerBasket, markerBasket: markerBasket, masterMessageBasket: masterMessageBasket, journeyDisplayController: journeyDisplayController)
        
        self.journeySyncRemoteInvocation = JourneySyncRemoteInvocation(api: api, journeyDisplayController: journeyDisplayController, journeySyncProgressListener: JourneySyncProgressListener(api: api))
        
        registerForEvents()
    }

    func registerForEvents() {
        api.bgEvents.registerForEvent("Master:init", listener: self)
        api.bgEvents.registerForEvent("Master:reload", listener: self)
        api.bgEvents.registerForEvent("Master:store", listener: self)
        api.bgEvents.registerForEvent("Master:resetSeenMarkers", listener: self)
        api.bgEvents.registerForEvent("Master:resetSeenMessages", listener: self)
        
        api.bgEvents.registerForEvent("JourneySync", listener: self)
        api.bgEvents.registerForEvent("Update", listener: self)
    }
    
    public func unregisterForEvents() {
        api.bgEvents.unregisterForEvent("Master:init", listener: self)
        api.bgEvents.unregisterForEvent("Master:reload", listener: self)
        api.bgEvents.unregisterForEvent("Master:store", listener: self)
        api.bgEvents.unregisterForEvent("Master:resetSeenMarkers", listener: self)
        api.bgEvents.unregisterForEvent("Master:resetSeenMessages", listener: self)
        
        api.bgEvents.unregisterForEvent("JourneySync", listener: self)
        api.bgEvents.unregisterForEvent("Update", listener: self)
    }
    
    public func onBuspassEvent(event: BuspassEvent) {
        let eventName = event.eventName
        if eventName == "Master:init" {
            let eventData = event.eventData as MasterEventData
            onMasterInit(eventData)
        }
        if eventName == "JourneySync" {
            let eventData = event.eventData as JourneySyncEventData
            journeySyncRemoteInvocation.perform(eventData.isForced)
        } else if eventName == "Update" {
            let eventData = event.eventData as UpdateEventData
            updateRemoteInvocation.perform(eventData.isForced)
        } else if eventName == "Master:reload" {
            let eventData = event.eventData as MasterEventData
            onMasterReload(eventData)
        }
        
    }
    
    func onMasterInit(eventData : MasterEventData) {
        let (error, good) = api.get()
        if !good {
            eventData.error = error
            eventData.returnStatus = "Error"
        } else {
            eventData.returnStatus = "MasterReady"
        }
        api.uiEvents.postEvent("Master:Init:return", data: eventData)
    }
    
    func onMasterReload(eventData : MasterEventData) {
        if (BLog.DEBUG) { BLog.logger.debug("emptying all baskets and stores") }
        journeyBasket.empty()
        journeyStore.empty()
        bannerBasket.empty()
        markerBasket.empty()
        masterMessageBasket.empty()
    }
    
    public func storeMaster() {
        
    }
}