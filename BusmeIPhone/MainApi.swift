//
//  MainApi.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/29/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class MainApi : ApiBase, EventsApi {
    var uiEvents : BuspassEventDistributor
    var bgEvents : BuspassEventDistributor
    var initialUrl : String
    
    init(httpClient : HttpClient, initialUrl : String) {
        self.uiEvents = BuspassEventDistributor(name: "UIEvents(Main)")
        self.bgEvents = BuspassEventDistributor(name: "BGEvents(Main)")
        self.initialUrl = initialUrl
        super.init(httpClient: httpClient)
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
}