//
//  UpdateRemoteInvoation.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/10/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class UpdateRemoteInvocation : RemoteInvocation {
    let busApi : BuspassApi
    public var banners : BannerRequestProcessor
    public var markers : MarkerRequestProcessor
    public var messages : MasterMessageRequestProcessor
    public var journeys : JourneyCurrentLocationRequestProcessor
    
    public init(
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

        super.init(api: api, url: "")
    }
    
    public override func getRequestUrl() -> String? {
        if busApi.isReady() {
            let query = busApi.getDefaultQuery().toString()
            let url = busApi.buspass!.updateUrl
            if url != nil {
                return url! + query
            }
        }
        return nil
    }
    
    public override func handleResponse(tag: Tag?) -> Bool {
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
    
}