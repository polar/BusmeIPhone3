//
//  Buspass.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/4/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class Buspass {
    public var version : String?
    public var mode : String?
    public var name : String?
    public var slug : String?
    public var authUrl : String?
    public var loginUrl : String?
    public var registerUrl : String?
    public var logoutUrl : String?
    public var oauthLoginUrl : String?
    public var oauthLogoutUrl : String?
    public var postloc_time_rate : String?
    public var postloc_dist_rate : String?
    public var curloc_time_rate : String?
    public var lon : String?
    public var lat : String?
    public var timezone : String?
    public var time : String?
    public var timeoffset : String?
    public var datefmt : String?
    public var getRouteJourneyIdsUrl : String?
    public var getRouteDefinitionUrl : String?
    public var getJourneyLocationUrl : String?
    public var getMultipleJourneyLocationsUrl : String?
    public var postJourneyLocationUrl : String?
    public var getMessageUrl : String?
    public var getMessagesUrl : String?
    public var getMarkersUrl : String?
    public var postFeedbackUrl : String?
    public var updateUrl : String?
    public var updateRate : String?
    public var activeStartDisplayThreshold : String?
    public var activeEndWaitThreshold : String?
    public var offRouteDistanceThreshold : String?
    public var offRouteCountThreshold : String?
    public var offRouteTimeThreshold : String?
    public var getRouteJourneyIds1Url : String?
    public var syncRate : String?
    public var box : String?
    public var markerClickThru : String?
    public var messageClickThru : String?
    public var bannerRefreshRate : String?
    public var bannerClickThru : String?
    public var bannerMaxImageSize : String?
    public var bannerImageUrl : String?
    public var helpUrl : String?
    public var initialMessages : [String]
    
    public init() {
        self.initialMessages = [String]();
    }
}