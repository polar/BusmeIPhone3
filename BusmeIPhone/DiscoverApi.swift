//
//  DiscoverApi.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/7/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class DiscoverApi : ApiBase, EventsApi {
    var uiEvents : BuspassEventDistributor
    var bgEvents : BuspassEventDistributor
    
    override init(httpClient : HttpClient) {
        self.uiEvents = BuspassEventDistributor(name: "UIEvents(Search)")
        self.bgEvents = BuspassEventDistributor(name: "BGEvents(Search)")
        super.init(httpClient: httpClient)
    }
    
    func discover(lon : Double, lat : Double, buffer : Double) -> (HttpStatusLine,[Master]) {
        return (HttpStatusLine(statusCode: 500, reasonPhrase: "Not initialized"),[Master]())
    }
    
    func discoverWithArgs(args : [String:AnyObject?]) -> (HttpStatusLine,[Master]) {
        return discover(args["lon"]! as Double, lat: args["lat"]! as Double, buffer:  args["buffer"]! as Double)
    }
    
    func findMaster(slug : String) -> (HttpStatusLine,Master?) {
        return (HttpStatusLine(statusCode: 500, reasonPhrase: "Not initialized"),nil);
    }
}