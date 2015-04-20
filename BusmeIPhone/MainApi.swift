//
//  MainApi.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/29/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

let OPM_TEST = "test"
let OPM_NORMAL = "normal"

let NORMAL_URL = "https://busme-apis.herokuapp.com/apis/d1/get"
let NORMAL_URL2 = "http://localhost/apis/d1/get"
let NORMAL_URL1 = "http://Polars-MacBook-Air.local:3002/apis/d1/get"
let NORMAL_URL4 = "http://adiron.com:3002/apis/d1/get"
let TEST_URL = "https://busme-apis.herokuapp.com/apis/td1/get"

class MainApi : ApiBase, EventsApi {
    var uiEvents : BuspassEventDistributor
    var bgEvents : BuspassEventDistributor
    var initialUrl : String
    var operationMode : String
    
    init(httpClient : HttpClient, mode: String) {
        self.uiEvents = BuspassEventDistributor(name: "UIEvents(Main)")
        self.bgEvents = BuspassEventDistributor(name: "BGEvents(Main)")
        self.initialUrl = ""
        self.operationMode = mode
        super.init(httpClient: httpClient)
        switchMode(mode)
    }
    
    func switchMode(mode : String) {
        switch(mode) {
        case OPM_TEST:
            initialUrl = TEST_URL
            break
        case OPM_NORMAL:
            initialUrl = NORMAL_URL
            break
        default:
            initialUrl = NORMAL_URL
        }
        self.operationMode = mode
    }
    
    func get() -> (HttpStatusLine, DiscoverApiVersion1?) {
        let response = getURLResponse(initialUrl)
        let status = response.getStatusLine()
        if status.statusCode == 200 {
            let tag = xmlParse(response.getEntity())
            if (tag != nil) {
                var api = DiscoverApiVersion1(httpClient: httpClient)
                api.discoverUrl = tag!.attributes["discover"]
                api.masterUrl = tag!.attributes["master"]
                if (api.discoverUrl != nil && api.masterUrl != nil) {
                    return (status, api)
                }
            }
            return (HttpStatusLine(statusCode: 1000, reasonPhrase: "Invalid Structure"), nil)
        }
        return (status, nil)
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}