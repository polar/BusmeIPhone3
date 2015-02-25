//
//  MasterController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/10/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

class MasterLogin {
    var masterSlug : String!
    var email : String = ""
    var authToken : String = ""
    
    init(masterSlug : String, email: String, authToken: String) {
        self.masterSlug = masterSlug
        self.email = email
        self.authToken = authToken
    }
    
    func saveToKeyChain() {
        Locksmith.saveData(["email": email, "authToken" : authToken],forUserAccount: masterSlug, inService: "busme")
    }
    
    class func getFromKeyChain(masterSlug : String) -> MasterLogin? {
        let (data, error) = Locksmith.loadDataForUserAccount(masterSlug, inService: "busme")
        if data != nil {
            let email = data!["email"] as? String
            let authToken = data!["authToken"] as? String
            if email != nil && authToken != nil {
                return MasterLogin(masterSlug: masterSlug, email: email!, authToken: authToken!)
            }
        }
        return nil
    }
}

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

class MasterController : BuspassEventListener {
    var api : BuspassApi
    var master : Master
    weak var mainController : MainController?
    
    var directory : String?
    var bannerBasket : BannerBasket
    var bannerPresentationController : BannerPresentationController
    var bannerStore : BannerStore
    
    var bannerForeground : BannerForeground
    var bannerBackground : BannerBackground
    
    var journeyBasket : JourneyBasket
    var journeyDisplayController : JourneyDisplayController
    var journeyStore : JourneyStore
    var journeyVisibilityController : JourneyVisibilityController
    var journeyDisplaySelectionController : JourneyDisplaySelectionController
    
    var markerBasket : MarkerBasket
    var markerPresentationController : MarkerPresentationController
    var markerStore : MarkerStore
    
    var markerForeground : MarkerForeground
    var markerBackground : MarkerBackground
    
    var masterMessageBasket : MasterMessageBasket
    var masterMessagePresentationController : MasterMessagePresentationController
    var masterMessageStore : MasterMessageStore
    
    var masterMessageForeground : MasterMessageForeground
    var masterMessageBackground : MasterMessageBackground
    
    //var loginForeground : LoginForeground
    var loginBackground : LoginBackground
    
    var journeyLocationPoster : JourneyLocationPoster
    var journeyEventController : JourneyEventController
    var journeyPostingController : JourneyPostingController
    
    var updateRemoteInvocation : UpdateRemoteInvocation
    var journeySyncRemoteInvocation : JourneySyncRemoteInvocation

    var externalStorageController : ExternalStorageController
    var storageSerializedController : StorageSerializeController
    
    
    init(api : BuspassApi, master: Master, mainController : MainController) {
        self.api = api
        self.master = master
        self.mainController = mainController
        
        let directory = mainController.configurator.getCacheDirectory()
        
        self.externalStorageController = ExternalStorageController(api: api, directory: directory)
        self.storageSerializedController = StorageSerializeController(api: api, externalStorageController: externalStorageController)
        
        self.bannerStore = BannerStore()
        self.bannerBasket = BannerBasket(bannerStore: bannerStore)
        self.bannerPresentationController = BannerPresentationController(api: api, basket: bannerBasket)
        self.bannerForeground = BannerForeground(api: api)
        self.bannerForeground.bannerPresentationController = bannerPresentationController
        self.bannerBackground = BannerBackground(api: api)
        
        let ms = storageSerializedController.retrieveStorage("\(master.slug!)-Markers.dat", api: api) as? MarkerStore
        self.markerStore = ms != nil ? ms! : MarkerStore()
        self.markerBasket = MarkerBasket(markerStore: markerStore)
        self.markerPresentationController = MarkerPresentationController(api: api, markerBasket: markerBasket)
        self.markerForeground = MarkerForeground(api: api)
        self.markerForeground.markerPresentationController = markerPresentationController
        self.markerBackground = MarkerBackground(api: api)
        
        let msgS = storageSerializedController.retrieveStorage("\(master.slug!)-Messages.dat", api: api) as? MasterMessageStore
        self.masterMessageStore = msgS != nil ? msgS! : MasterMessageStore()
        self.masterMessageBasket = MasterMessageBasket(masterMessageStore: masterMessageStore)
        self.masterMessagePresentationController = MasterMessagePresentationController(api: api, basket: masterMessageBasket)
        self.masterMessageBasket.masterMessageController = masterMessagePresentationController
        self.masterMessageForeground = MasterMessageForeground(api: api)
        self.masterMessageForeground.masterMessagePresentationController = masterMessagePresentationController
        self.masterMessageBackground = MasterMessageBackground(api: api)
        
        let js = storageSerializedController.retrieveStorage("\(master.slug!)-Journeys.dat", api: api) as? JourneyStore
        self.journeyStore = js != nil ? js! : JourneyStore(name: master.slug!)
        journeyStore.name = master.slug!
        self.journeyBasket = JourneyBasket(api: api, journeyStore: journeyStore)
        self.journeyDisplayController = JourneyDisplayController(api: api, basket: journeyBasket)
        self.journeyVisibilityController = JourneyVisibilityController(api: api, controller: journeyDisplayController)
        self.journeyDisplaySelectionController = JourneyDisplaySelectionController(api : api, journeyDisplayController: journeyDisplayController)
        
        
        self.updateRemoteInvocation = UpdateRemoteInvocation(api: api, bannerBasket: bannerBasket, markerBasket: markerBasket, masterMessageBasket: masterMessageBasket, journeyDisplayController: journeyDisplayController)
        
        self.journeySyncRemoteInvocation = JourneySyncRemoteInvocation(api: api, journeyDisplayController: journeyDisplayController, journeySyncProgressListener: JourneySyncProgressListener(api: api))
        
        self.journeyLocationPoster = JourneyLocationPoster(api: api)
        self.journeyEventController = JourneyEventController(api: api)
        self.journeyPostingController = JourneyPostingController(api: api)
        
        //self.loginForeground = LoginForeground(api: api)
        self.loginBackground = LoginBackground(api: api)
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
        
        api.uiEvents.registerForEvent("LoginEvent", listener: self)
    }
    
    func unregisterForEvents() {
        api.bgEvents.unregisterForEvent("Master:init", listener: self)
        api.bgEvents.unregisterForEvent("Master:reload", listener: self)
        api.bgEvents.unregisterForEvent("Master:store", listener: self)
        api.bgEvents.unregisterForEvent("Master:resetSeenMarkers", listener: self)
        api.bgEvents.unregisterForEvent("Master:resetSeenMessages", listener: self)
        
        api.bgEvents.unregisterForEvent("JourneySync", listener: self)
        api.bgEvents.unregisterForEvent("Update", listener: self)
        api.uiEvents.unregisterForEvent("LoginEvent", listener: self)
    }
    
    func unregisterForEventsAllComponents() {
        unregisterForEvents()
        bannerForeground.unregisterForEvents()
        bannerBackground.unregisterForEvents()
        markerBackground.unregisterForEvents()
        markerForeground.unregisterForEvents()
        masterMessageForeground.unregisterForEvents()
        masterMessageBackground.unregisterForEvents()
    
        journeyDisplayController.unregisterForEvents()
        journeyLocationPoster.unregisterForEvents()
        journeyEventController.unregisterForEvents()
        
        //loginForeground.unregisterForEvents()
        loginBackground.unregisterForEvents()

    }
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventName = event.eventName
        if eventName == "Master:init" {
            let eventData = event.eventData as MasterEventData
            onMasterInit(eventData)
        } else if eventName == "JourneySync" {
            let eventData = event.eventData as JourneySyncEventData
            journeySyncRemoteInvocation.perform(eventData.isForced)
        } else if eventName == "Update" {
            let eventData = event.eventData as UpdateEventData
            updateRemoteInvocation.perform(eventData.isForced)
        } else if eventName == "Master:reload" {
            let eventData = event.eventData as MasterEventData
            onMasterReload(eventData)
        } else if eventName == "Master:resetSeenMarkers" {
            let eventData = event.eventData as MasterEventData
            onMasterResetSeenMarkers(eventData)
        } else if eventName == "Master:resetSeenMessages" {
            let eventData = event.eventData as MasterEventData
            onMasterResetSeenMessages(eventData)
        } else if eventName == "Master:store" {
            let eventData = event.eventData as MasterEventData
            storeMaster()
        } else if eventName == "LoginEvent" {
            let eventData = event.eventData as LoginEventData
            onLoginEvent(eventData)
        }
    }
    
    func onLoginEvent(eventData: LoginEventData) {
        let loginManager = eventData.loginManager
        let login = loginManager.login
        switch login.loginState {
        case LoginState.LS_LOGIN_SUCCESS, LoginState.LS_REGISTER_SUCCESS, LoginState.LS_AUTHTOKEN_SUCCESS:
            let email = login.email
            let authToken = login.authToken
            if email != nil && authToken != nil {
                let masterLogin = MasterLogin(masterSlug: master.slug!, email: email!, authToken: authToken!)
                masterLogin.saveToKeyChain()
            }
            break
        default:
            break
        }
    }
    
    func onMasterInit(eventData : MasterEventData) {
        let (error, good) = api.get()
        if !good {
            eventData.error = error
            eventData.returnStatus = "Error"
        } else {
            eventData.returnStatus = "MasterReady"
            let masterLogin = MasterLogin.getFromKeyChain(master.slug!)
            if masterLogin != nil {
                let login = Login()
                login.loginState = LoginState.LS_AUTHTOKEN
                login.email = masterLogin!.email
                login.authToken = masterLogin!.authToken
                login.quiet = true
                let lm = LoginManager(api: api)
                lm.login = login
                let evd = LoginEventData(loginManager: lm)
                api.bgEvents.postEvent("LoginEvent", data: evd)
            }
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
        api.uiEvents.postEvent("Master:Reload:return", data: eventData)
    }
    
    func onMasterResetSeenMarkers(eventData : MasterEventData) {
        if (BLog.DEBUG) { BLog.logger.debug("reseting all markers") }
        markerBasket.resetMarkers(now: UtilsTime.current())
    }
    
    func onMasterResetSeenMessages(eventData : MasterEventData) {
        if (BLog.DEBUG) { BLog.logger.debug("reseting all messages") }
        masterMessageBasket.resetMasterMessages(now: UtilsTime.current())
    }
    
    func storeMaster() {
        storageSerializedController.cacheStorage(journeyStore, filename: "\(master.slug!)-Journeys.dat", api: api)
        storageSerializedController.cacheStorage(masterMessageStore, filename: "\(master.slug!)-Messages.dat", api: api)
        storageSerializedController.cacheStorage(markerStore, filename: "\(master.slug!)-Markers.dat", api: api)
    }
    
    func reloadStores() {
        replaceMarkerStore()
        replaceMasterMessageStore()
        replaceJourneyStore()
        
        self.updateRemoteInvocation = UpdateRemoteInvocation(api: api, bannerBasket: bannerBasket, markerBasket: markerBasket, masterMessageBasket: masterMessageBasket, journeyDisplayController: journeyDisplayController)
        
        self.journeySyncRemoteInvocation = JourneySyncRemoteInvocation(api: api, journeyDisplayController: journeyDisplayController, journeySyncProgressListener: JourneySyncProgressListener(api: api))
    }
    
    func replaceMarkerStore() {
        self.markerBackground.unregisterForEvents()
        self.markerForeground.unregisterForEvents()
        
        let ms = storageSerializedController.retrieveStorage("\(master.slug!)-Markers.dat", api: api) as? MarkerStore
        self.markerStore = ms != nil ? ms! : MarkerStore()
        self.markerBasket = MarkerBasket(markerStore: markerStore)
        self.markerPresentationController = MarkerPresentationController(api: api, markerBasket: markerBasket)
        self.markerForeground = MarkerForeground(api: api)
        self.markerForeground.markerPresentationController = markerPresentationController
        self.markerBackground = MarkerBackground(api: api)
    }
    
    func replaceMasterMessageStore() {
        self.masterMessageForeground.unregisterForEvents()
        self.masterMessageBackground.unregisterForEvents()
        
        let msgS = storageSerializedController.retrieveStorage("\(master.slug!)-Messages.dat", api: api) as? MasterMessageStore
        self.masterMessageStore = msgS != nil ? msgS! : MasterMessageStore()
        self.masterMessageBasket = MasterMessageBasket(masterMessageStore: masterMessageStore)
        self.masterMessagePresentationController = MasterMessagePresentationController(api: api, basket: masterMessageBasket)
        self.masterMessageBasket.masterMessageController = masterMessagePresentationController
        self.masterMessageForeground = MasterMessageForeground(api: api)
        self.masterMessageForeground.masterMessagePresentationController = masterMessagePresentationController
        self.masterMessageBackground = MasterMessageBackground(api: api)
    }
    
    func replaceJourneyStore() {
        
        let js = storageSerializedController.retrieveStorage("\(master.slug!)-Journeys.dat", api: api) as? JourneyStore
        self.journeyStore = js != nil ? js! : JourneyStore(name: master.slug!)
        self.journeyStore.name = master.slug!
        self.journeyBasket = JourneyBasket(api: api, journeyStore: journeyStore)
        self.journeyDisplayController = JourneyDisplayController(api: api, basket: journeyBasket)
        self.journeyVisibilityController = JourneyVisibilityController(api: api, controller: journeyDisplayController)
        self.journeyDisplaySelectionController = JourneyDisplaySelectionController(api : api, journeyDisplayController: journeyDisplayController)
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC Master(\(master.slug!)") }
    }
}