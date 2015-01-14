//
//  DiscoverApiVersion1.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/7/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class DiscoverApiVersion1 : DiscoverApi {
    public var initialUrl : String
    public var discoverUrl : String?
    public var masterUrl : String?
    public var uiEvents : BuspassEventDistributor
    public var bgEvents : BuspassEventDistributor
    
    public init(httpClient : HttpClient, initialUrl : String) {
        self.initialUrl = initialUrl
        self.uiEvents = BuspassEventDistributor(name: "UIEvents(Search)")
        self.bgEvents = BuspassEventDistributor(name: "BGEvents(Search)")
        super.init(httpClient: httpClient)
    }
    
    public override func get() -> (HttpStatusLine, DiscoverApiVersion1?) {
        let response = getURLResponse(initialUrl)
        let status = response.getStatusLine()
        if status.statusCode == 200 {
            let tag = xmlParse(response.getEntity())
            if (tag != nil) {
                self.discoverUrl = tag!.attributes["discover"]
                self.masterUrl = tag!.attributes["master"]
            }
            if (self.discoverUrl != nil && masterUrl != nil) {
                return (status, self)
            }
            return (HttpStatusLine(statusCode: 1000, reasonPhrase: "Invalid Structure"), nil)
        }
        return (status, nil)
    }
    
    public override func discover(lon : Double, lat : Double, buffer : Double) -> (HttpStatusLine, [Master]){
        var masters = [Master]();
        let url = "\(discoverUrl!)?lon=\(lon)&lat=\(lat)&buf=\(buffer)"
        let response = getURLResponse(url)
        let status = response.getStatusLine()
        if status.statusCode == 200 {
            let tag = xmlParse(response.getEntity())
            if (tag != nil) {
                if ("masters" == tag!.name.lowercaseString) {
                    for child in tag!.childNodes {
                        if ("master" == child.name.lowercaseString) {
                            let master = Master(tag: child)
                            if master.isValid() {
                                masters.append(master)
                            }
                        }
                    }
                }
            }
        }
        return (status, masters)
    }
    
    public override func findMaster(slug : String) -> (HttpStatusLine, Master?) {
        let url = "\(masterUrl!)?slug=\(slug)"
        let response = getURLResponse(url)
        let status = response.getStatusLine()
        if (status.statusCode == 200) {
            let tag = xmlParse(response.getEntity())
            if (tag != nil) {
                if ("master" == tag!.name.lowercaseString) {
                    let master = Master(tag: tag!)
                    if master.isValid() {
                        return (status, master)
                    } else {
                        return (HttpStatusLine(statusCode: 1000, reasonPhrase: "Structure Invalid"), nil)
                    }
                } else {
                    return (HttpStatusLine(statusCode: 1000, reasonPhrase: "Not Found"), nil)
                }
            } else {
                return (HttpStatusLine(statusCode: 1000, reasonPhrase: "No Answser"), nil)
            }
        } else {
            return (status, nil)
        }
    }

    
}