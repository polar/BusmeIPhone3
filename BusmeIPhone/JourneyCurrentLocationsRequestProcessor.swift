//
//  JourneyLocationRequestProcessor.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class JourneyCurrentLocationRequestProcessor : ArgumentPreparer, ResponseProcessor {
    unowned var journeyDisplayController : JourneyDisplayController
    
    init(controller : JourneyDisplayController) {
        self.journeyDisplayController = controller
    }
    
    func getArguments() -> [String : [String]]? {
        var args = [String:[String]]()
        var ids = [String]()
        for journeyDisplay in journeyDisplayController.getJourneyDisplays().filter({(x) in x.route.isJourney() && x.isPathVisible()}) {
            ids.append(journeyDisplay.route.id!)
        }
        args["journey_ids"] = ids
        return args
    }
    
    func onResponse(response: Tag) {
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
    
    func pushCurrentLocations( journeyLocations : [String : JourneyLocation] ) {
        let journeyBasket = journeyDisplayController.journeyBasket
        for key in journeyLocations.keys {
            let loc = journeyLocations[key]!
            let journey = journeyBasket.getRoute(key)
            if (journey != nil) {
                let (newLoc, lastLoc) = journey!.pushCurrentLocation(loc)
                if lastLoc == nil || samePoint(newLoc, loc2: lastLoc!) {
                    if (BLog.DEBUG) {BLog.logger.debug("Location received for route \(journey!.name)")}
                }
                let vid = loc.vid
                if vid != nil {
                    if journey!.vid == nil {
                        if BLog.DEBUG {BLog.logger.debug("New Vid \(vid) for route \(journey!.name)")}
                        journey!.vid = vid
                    } else if vid != journey!.vid {
                        if BLog.DEBUG {BLog.logger.debug("VID Change Old Vid \(journey!.vid) New Vid \(vid) for route \(journey!.name)")}
                        journey!.vid = vid
                    }
                } else {
                    if journey!.vid != nil {
                        if BLog.DEBUG {BLog.logger.debug("VID Nulled Old Vid \(journey!.vid)  for route \(journey!.name)")}
                    }
                    journey!.vid = nil
                }
            }
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}