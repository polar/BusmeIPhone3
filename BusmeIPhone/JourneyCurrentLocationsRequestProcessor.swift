//
//  JourneyLocationRequestProcessor.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class JourneyCurrentLocationRequestProcessor : ArgumentPreparer, ResponseProcessor {
    public var journeyDisplayController : JourneyDisplayController
    
    public init(controller : JourneyDisplayController) {
        self.journeyDisplayController = controller
    }
    
    public func getArguments() -> [String : [String]]? {
        var args = [String:[String]]()
        var ids = [String]()
        for journeyDisplay in journeyDisplayController.getJourneyDisplays().filter({(x) in x.route.isJourney() && x.isPathVisible()}) {
            ids.append(journeyDisplay.route.id!)
        }
        args["journey_ids"] = ids
        return args
    }
    
    public func onResponse(response: Tag) {
        var journeyLocations = [String : JourneyLocation]()
        for child in response.childNodes {
            if child.name.lowercaseString == "jps" {
                for bspec in child.childNodes {
                    if bspec.name.lowercaseString == "jp" {
                        let journeyLocation = JourneyLocation(tag: bspec)
                        if journeyLocation.isValid() {
                            journeyLocations[journeyLocation.getRouteId()] = journeyLocation
                        }
                    }
                }
            }
        }
        pushCurrentLocations(journeyLocations)
    }
    
    func samePoint(loc1 : GeoPoint, loc2 : GeoPoint) -> Bool{
        return GeoCalc.equalCoordinates(loc1, c2: loc2)
    }
    
    public func pushCurrentLocations( journeyLocations : [String : JourneyLocation] ) {
        let journeyBasket = journeyDisplayController.journeyBasket
        for key in journeyLocations.keys {
            let loc = journeyLocations[key]!
            let journey = journeyBasket.getRoute(key)
            if (journey != nil) {
                let (newLoc, lastLoc) = journey!.pushCurrentLocation(loc)
                if lastLoc == nil || samePoint(newLoc, loc2: lastLoc!) {
                    if (BLog.DEBUG) {BLog.logger.debug("Location received for route \(journey!.name)")}
                }
            }
        }
    }
}