//
//  Buspass.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/4/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class Buspass {
    var version : String?
    var mode : String?
    var name : String?
    var slug : String?
    var authUrl : String?
    var loginUrl : String?
    var registerUrl : String?
    var logoutUrl : String?
    var oauthLoginUrl : String?
    var oauthLogoutUrl : String?
    var postloc_time_rate : String?
    var postloc_dist_rate : String?
    var curloc_time_rate : String?
    var lon : String?
    var lat : String?
    var timezone : String?
    var time : String?
    var timeoffset : String?
    var datefmt : String?
    var getRouteJourneyIdsUrl : String?
    var getRouteDefinitionUrl : String?
    var getJourneyLocationUrl : String?
    var getMultipleJourneyLocationsUrl : String?
    var postJourneyLocationUrl : String?
    var getMessageUrl : String?
    var getMessagesUrl : String?
    var getMarkersUrl : String?
    var postFeedbackUrl : String?
    var updateUrl : String?
    var updateRate : String?
    var activeStartDisplayThreshold : String?
    var activeEndWaitThreshold : String?
    var offRouteDistanceThreshold : String?
    var offRouteCountThreshold : String?
    var offRouteTimeThreshold : String?
    var getRouteJourneyIds1Url : String?
    var syncRate : String?
    var box : String?
    var markerClickThru : String?
    var messageClickThru : String?
    var bannerRefreshRate : String?
    var bannerClickThru : String?
    var bannerMaxImageSize : String?
    var bannerImageUrl : String?
    var helpUrl : String?
    var initialMessages : [MasterMessage]
    
    init() {
        self.initialMessages = [MasterMessage]();
    }
}