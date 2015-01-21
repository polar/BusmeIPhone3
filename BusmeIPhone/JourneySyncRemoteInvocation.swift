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

public class JourneySyncUpdateProgressListener : InvocationProgressListener {
    var journeySyncProgressListener : JourneySyncProgressListener
    
    public init(journeySyncProgressListener : JourneySyncProgressListener) {
        self.journeySyncProgressListener = journeySyncProgressListener
    }
    public override func onUpdateStart(time: TimeValue64, isForced: Bool) {
        journeySyncProgressListener.onBegin(isForced)
    }
    public override func onRequestStart(time: TimeValue64) {
        journeySyncProgressListener.onSyncStart()
    }
    public override func onUpdateFinish(makeRequest: Bool, time: TimeValue64) {
        journeySyncProgressListener.onDone()
    }
}

public class JourneySyncRemoteInvocation : RemoteInvocation {
    let busApi : BuspassApi
    public var journeyDisplayController : JourneyDisplayController
    public var journeySyncRequestProcessor : JourneySyncRequestProcessor
    public var journeySyncProgressListener : JourneySyncProgressListener
    public var journeySyncUpdateProgressListener : JourneySyncUpdateProgressListener
    
    public init(api : BuspassApi, journeyDisplayController : JourneyDisplayController, journeySyncProgressListener : JourneySyncProgressListener) {
        self.journeyDisplayController = journeyDisplayController
        self.journeySyncProgressListener = journeySyncProgressListener
        self.journeySyncRequestProcessor = JourneySyncRequestProcessor(journeyBasket: journeyDisplayController.journeyBasket, progressListener: journeySyncProgressListener)
        self.journeySyncUpdateProgressListener = JourneySyncUpdateProgressListener(journeySyncProgressListener: journeySyncProgressListener)
        self.busApi = api
        super.init(api: api, url: nil)
        
        addArgumentPreparer(journeySyncRequestProcessor)
        addResponseProcessor(journeySyncRequestProcessor)
    }
    
    public override func getRequestUrl() -> String? {
        if busApi.isReady() {
            let query = busApi.getDefaultQuery().toString()
            return busApi.buspass!.getRouteJourneyIds1Url! + query
        }
        return nil
    }
    
    public override func handleResponse(tag: Tag?) -> Bool {
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
    
    public func perform(isForced : Bool) {
        invoke(journeySyncUpdateProgressListener, isForced: isForced)
    }
    
}