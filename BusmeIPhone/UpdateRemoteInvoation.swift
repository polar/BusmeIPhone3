//
//  UpdateRemoteInvoation.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/10/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation


class UpdateEventData {
    var isForced : Bool
    init(isForced : Bool) {
        self.isForced = isForced
    }
}

class UpdateProgressEventData {
    var action : Int
    var time : TimeValue64?
    var isForced : Bool = false
    var error : HttpStatusLine?
    var makeRequest : Bool?
    init(action: Int, time: TimeValue64, isForced : Bool) {
        self.action = action
        self.time = time
        self.isForced = isForced
    }
    
    init(action: Int, time: TimeValue64) {
        self.action = action
        self.time = time
    }
    init(action: Int) {
        self.action = action
    }
    init(action: Int, makeRequest: Bool) {
        self.action = action
        self.makeRequest = makeRequest
    }
    
    init(action: Int, error: HttpStatusLine) {
        self.action = action
        self.error = error
    }
}

class UpdateRemoteInvocationProgressListener : InvocationProgressListener {
    var api : BuspassApi
    
    init(api : BuspassApi) {
        self.api = api
    }
    
    override func onUpdateStart(time : TimeValue64, isForced : Bool) {
        api.uiEvents.postEvent("UpdateProgress",
            data: UpdateProgressEventData(action: InvocationProgressEvent.U_START, time: time, isForced: isForced))
    }
    
    override func onArgumentsStart() {
        api.uiEvents.postEvent("UpdateProgress",
            data: UpdateProgressEventData(action: InvocationProgressEvent.U_ARG_START ))
    }
    override func onArgumentsFinish(makeRequest : Bool) {
        api.uiEvents.postEvent("UpdateProgress",
            data: UpdateProgressEventData(action: InvocationProgressEvent.U_ARG_START, makeRequest: makeRequest))
    }
    override func onRequestStart(time : TimeValue64) {
        api.uiEvents.postEvent("UpdateProgress",
            data: UpdateProgressEventData(action: InvocationProgressEvent.U_REQ_START , time: time))
    }
    override func onRequestIOError(status : HttpStatusLine) {
        api.uiEvents.postEvent("UpdateProgress",
            data: UpdateProgressEventData(action: InvocationProgressEvent.U_REQ_IOERROR, error: status))
    }
    override func onRequestFinish(time : TimeValue64) {
        api.uiEvents.postEvent("UpdateProgress",
            data: UpdateProgressEventData(action: InvocationProgressEvent.U_REQ_FIN, time: time))
    }
    override func onResponseStart() {
        api.uiEvents.postEvent("UpdateProgress",
            data: UpdateProgressEventData(action: InvocationProgressEvent.U_RESP_START))
    }
    override func onResponseFinish() {
        api.uiEvents.postEvent("UpdateProgress",
            data: UpdateProgressEventData(action: InvocationProgressEvent.U_RESP_FIN))
    }
    override func onUpdateFinish(makeRequest : Bool, time : TimeValue64) {
        api.uiEvents.postEvent("UpdateProgress",
            data: UpdateProgressEventData(action: InvocationProgressEvent.U_FINISH, time: time))
    }
}

class UpdateRemoteInvocation : RemoteInvocation {
    let busApi : BuspassApi
    var banners : BannerRequestProcessor
    var markers : MarkerRequestProcessor
    var messages : MasterMessageRequestProcessor
    var journeys : JourneyCurrentLocationRequestProcessor
    var updateProgressListener : UpdateRemoteInvocationProgressListener
    
    init(
        api : BuspassApi,
        bannerBasket : BannerBasket,
        markerBasket : MarkerBasket,
        masterMessageBasket : MasterMessageBasket,
        journeyDisplayController : JourneyDisplayController) {
        self.banners = BannerRequestProcessor(bannerBasket: bannerBasket)
        self.markers = MarkerRequestProcessor(markerBasket: markerBasket)
        self.messages = MasterMessageRequestProcessor(masterMessageBasket: masterMessageBasket)
        self.journeys = JourneyCurrentLocationRequestProcessor(controller: journeyDisplayController)
        self.busApi = api as BuspassApi
        self.updateProgressListener = UpdateRemoteInvocationProgressListener(api: api)
        super.init(api: api, url: "")
        self.addArgumentPreparer(banners)
        self.addArgumentPreparer(markers)
        self.addArgumentPreparer(messages)
        self.addArgumentPreparer(journeys)
        self.addResponseProcessor(banners)
        self.addResponseProcessor(markers)
        self.addResponseProcessor(messages)
        self.addResponseProcessor(journeys)
    }
    
    func perform(isForced : Bool) {
        self.invoke(updateProgressListener, isForced: isForced)
    }
    
    override func getRequestUrl() -> String? {
        if busApi.isReady() {
            let query = busApi.getDefaultQuery().toString()
            let url = busApi.buspass!.updateUrl
            if url != nil {
                return url! + query
            }
        }
        return nil
    }
    
    override func handleResponse(tag: Tag?) -> Bool {
        if tag != nil {
            if "response" == tag!.name.lowercaseString {
                let updateRate = tag!.attributes["updateRate"]
                let syncRate = tag!.attributes["syncRate"]
                if updateRate != nil {
                    busApi.updateRate = (updateRate! as NSString).integerValue
                }
                if syncRate != nil {
                    busApi.syncRate = (syncRate! as NSString).integerValue
                }
                return true
            }
        }
        return false
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
    
}