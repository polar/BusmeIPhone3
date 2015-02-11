//
//  JourneySyncRemoteInvocation.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/13/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class JourneySyncEventData {
    var isForced : Bool
    init(isForced : Bool) {
        self.isForced = isForced
    }
}

class JourneySyncUpdateProgressListener : InvocationProgressListener {
    var journeySyncProgressListener : JourneySyncProgressListener
    
    init(journeySyncProgressListener : JourneySyncProgressListener) {
        self.journeySyncProgressListener = journeySyncProgressListener
    }
    override func onUpdateStart(time: TimeValue64, isForced: Bool) {
        journeySyncProgressListener.onBegin(isForced)
    }
    override func onRequestStart(time: TimeValue64) {
        journeySyncProgressListener.onSyncStart()
    }
    override func onUpdateFinish(makeRequest: Bool, time: TimeValue64) {
        journeySyncProgressListener.onDone()
    }
}

class JourneySyncRemoteInvocation : RemoteInvocation {
    let busApi : BuspassApi
    var journeyDisplayController : JourneyDisplayController
    var journeySyncRequestProcessor : JourneySyncRequestProcessor
    var journeySyncProgressListener : JourneySyncProgressListener
    var journeySyncUpdateProgressListener : JourneySyncUpdateProgressListener
    
    init(api : BuspassApi, journeyDisplayController : JourneyDisplayController, journeySyncProgressListener : JourneySyncProgressListener) {
        self.journeyDisplayController = journeyDisplayController
        self.journeySyncProgressListener = journeySyncProgressListener
        self.journeySyncRequestProcessor = JourneySyncRequestProcessor(journeyBasket: journeyDisplayController.journeyBasket, progressListener: journeySyncProgressListener)
        self.journeySyncUpdateProgressListener = JourneySyncUpdateProgressListener(journeySyncProgressListener: journeySyncProgressListener)
        self.busApi = api
        super.init(api: api, url: nil)
        
        addArgumentPreparer(journeySyncRequestProcessor)
        addResponseProcessor(journeySyncRequestProcessor)
    }
    
    override func getRequestUrl() -> String? {
        if busApi.isReady() {
            let query = busApi.getDefaultQuery().toString()
            return busApi.buspass!.getRouteJourneyIds1Url! + query
        }
        return nil
    }
    
    override func handleResponse(tag: Tag?) -> Bool {
        if tag != nil {
            if "response" == tag!.name.lowercaseString {
                let updateRate = tag!.attributes["updateRate"] as NSString?
                let syncRate = tag!.attributes["syncRate"] as NSString?
                if updateRate != nil {
                    let rate = updateRate!.integerValue
                    busApi.updateRate = rate
                }
                if syncRate != nil {
                    let rate = syncRate!.integerValue
                    busApi.syncRate = rate
                }
                return true
            }
        }
        return false
    }
    
    func perform(isForced : Bool) {
        invoke(journeySyncUpdateProgressListener, isForced: isForced)
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
    
}