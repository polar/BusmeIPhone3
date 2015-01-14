//
//  JourneySyncRequestProcessor.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class JourneySyncRequestProcessor : ArgumentPreparer, ResponseProcessor {
    public var journeyBasket : JourneyBasket
    public var progressListener : JourneySyncProgressListener?
    
    public init(journeyBasket : JourneyBasket) {
        self.journeyBasket = journeyBasket
    }
    
    public init(journeyBasket : JourneyBasket, progressListener: JourneySyncProgressListener) {
        self.journeyBasket = journeyBasket
        self.progressListener = progressListener
    }
    
    
    public func getArguments() -> [String : [String]]? {
        var args = [String:[String]]()
        var routes = [String]()
        var versions = [String]()
        for route in journeyBasket.getAllRoutes() {
            routes.append(route.id!)
            versions.append("\(route.version)")
        }
        args["route_ids[]"] = routes
        args["versions[]"] = versions
        return args
    }
    
    public func onResponse(response: Tag) {
        var nameids = [NameId]()
        for tag in response.childNodes {
            if "r" == tag.name.lowercaseString {
                nameids.append(NameId(args: tag.text!.componentsSeparatedByString(",")))
            } else if "j" == tag.name.lowercaseString {
                nameids.append(NameId(args: tag.text!.componentsSeparatedByString(",")))
            }
        }
        progressListener?.onSyncEnd(nameids.count)
        journeyBasket.sync(nameids, progress: progressListener, ioError: progressListener)
    }
    
}