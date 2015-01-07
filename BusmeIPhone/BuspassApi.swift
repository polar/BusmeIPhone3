//
//  BuspassApi.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/4/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class BuspassApi : ApiBase {
    public var apiURL : String
    public var master_slug : String
    public var appVersion : String
    public var platformName : String
    public var buspass : Buspass?
    public var ready : Bool = false;
    public var syncRate : Int = 60 * 1000;
    public var updateRate : Int = 60 * 1000;
    public var activeStartDisplayThreshold : Double = 60 * 1000;
    public var busmeAppVersionString : String = "iPhone 1.0.0"
    //public var loginManager : LoginManager?
    public var uiEvents : String?
    public var bgEvents : String?
    public var loginCredentials : String?
    public var startReporting : Boolean?
    public var offRouteDistanceThreshold : Int = 1000;
    public var offRouteCountThreshold : Int = 20
    public var offRouteTimeThreshold : Int = 60 * 1000
    
    public init(httpClient: HttpClient, url : String, masterSlug : String, appVersion: String, platformName : String) {
        self.apiURL = url
        self.master_slug = masterSlug
        self.appVersion = appVersion
        self.platformName = platformName
        super.init(httpClient: httpClient)
    }
}