//
//  MasterController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/10/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

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
        
        registerForEvents()
    }

    func registerForEvents() {
        api.bgEvents.registerForEvent("Master:init", listener: self)
        api.bgEvents.registerForEvent("Master:reload", listener: self)
        api.bgEvents.registerForEvent("Master:store", listener: self)
        api.bgEvents.registerForEvent("Master:resetSeenMarkers", listener: self)
        api.bgEvents.registerForEvent("Master:resetSeenMessages", listener: self)
    }
    
    public func unregisterForEvents() {
        api.bgEvents.unregisterForEvent("Master:init", listener: self)
        api.bgEvents.unregisterForEvent("Master:reload", listener: self)
        api.bgEvents.unregisterForEvent("Master:store", listener: self)
        api.bgEvents.unregisterForEvent("Master:resetSeenMarkers", listener: self)
        api.bgEvents.unregisterForEvent("Master:resetSeenMessages", listener: self)
    }
    
    public func onBuspassEvent(event: BuspassEvent) {
        
    }
}