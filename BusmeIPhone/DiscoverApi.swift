//
//  DiscoverApi.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/7/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class DiscoverApi : ApiBase {
    
    public override init(httpClient : HttpClient) {
        super.init(httpClient: httpClient)
    }
    public func get() -> (HttpStatusLine, DiscoverApi?)  {
        return (HttpStatusLine(statusCode: 500, reasonPhrase: "Not initialized"),nil);
    }
    public func discover(lon : Double, lat : Double, buffer : Double) -> (HttpStatusLine,[Master]) {
        return (HttpStatusLine(statusCode: 500, reasonPhrase: "Not initialized"),[Master]())
    }
    public func discoverWithArgs(args : [String:AnyObject?]) -> (HttpStatusLine,[Master]) {
        return discover(args["lon"]! as Double, lat: args["lat"]! as Double, buffer:  args["buffer"]! as Double)
    }
    public func findMaster(slug : String) -> (HttpStatusLine,Master?) {
        return (HttpStatusLine(statusCode: 500, reasonPhrase: "Not initialized"),nil);
    }
}