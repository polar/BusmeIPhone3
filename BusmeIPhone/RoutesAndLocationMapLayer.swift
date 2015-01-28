//
//  RoutesAndLocationMapLayer.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/26/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

struct Disposition {
    static let TRACK = 1
    static let HIGHLIGHT = 2
    static let NORMAL = 3
}
struct IconType {
    static let NORMAL = 1
    static let REPORTING = 2
    static let TOO_EARLY = 3
    static let START = 4
}

struct LocatorArgs {
    let journeyDisplay : JourneyDisplay
    let currentLocation : GeoPoint
    let currentDirection : Double
    let currentDistance : Double
    let currentTimeDiff : Double
    let onRoute : Bool
    let isReporting : Bool
    let isReported : Bool
    let startMeasure : Double
    let disposition : Int
    let iconType : Int
}

struct PatternArgs {
    let journeyPattern : JourneyPattern
    let disposition : Int
}


class RouteAndLocationsMapLayer {
    
    var api : BuspassApi
    var journeyDisplayController : JourneyDisplayController
    var journeyLocationPoster : JourneyLocationPoster
    
    init(api : BuspassApi, journeyDisplayController : JourneyDisplayController, journeyLocationPoster : JourneyLocationPoster ) {
        self.api = api
        self.journeyDisplayController = journeyDisplayController
        self.journeyLocationPoster = journeyLocationPoster
    }
    
    func getCurrentLocation() -> Location? {
        return journeyLocationPoster.getCurrentLocation()
    }
    
    func getJourneyLocator(journeyDisplay : JourneyDisplay, disposition : Int) -> LocatorArgs? {
        let timeNow = UtilsTime.current()
        var onRoute = false
        var isReporting = false
        var isReported = false
        var currentLocation : GeoPoint? = nil
        var currentBearing : Double? = nil
        var currentDistance : Double? = nil
        var currentTimeDiff : Double? = nil
        if journeyDisplay.route.isReporting() {
            isReporting = true
            isReported = true
            let loc = getCurrentLocation()
            if loc != nil {
                currentLocation = GeoCalc.toGeoPoint(loc!)
                currentBearing = loc!.bearing
                let points = GeoPathUtils.whereOnPath(journeyDisplay.route.getPaths()[0], buffer: 60.0, c3: currentLocation!)
                var first : DGeoPoint? = nil
                for gp in points {
                    if gp.distance > 0 {
                        if journeyDisplay.route.lastKnownDistance != nil && gp.distance > journeyDisplay.route.lastKnownDistance! {
                            currentBearing = gp.bearing
                            currentDistance = gp.distance
                            onRoute = true
                            break
                        }
                    }
                }
                onRoute |= (first != nil)
                if first != nil {
                    if currentBearing == nil {
                        currentBearing = first!.bearing
                    }
                    if currentDistance == nil {
                        currentDistance = first!.distance
                    }
                }
            }
        }
        if currentLocation == nil {
            let route = journeyDisplay.route
            isReported = route.isReported()
            currentLocation = route.lastKnownLocation
            currentBearing = route.lastKnownDirection
            currentDistance = route.lastKnownDistance
            currentTimeDiff = route.lastKnownTimediff
            onRoute = route.onRoute
        }
        var iconType = IconType.NORMAL
        var startingMeasure = journeyDisplay.route.getStartingMeasure(api.activeStartDisplayThreshold, time: timeNow)
        if isReporting {
            if currentLocation != nil {
                iconType = IconType.REPORTING
            } else {
                // We do not place a locator
                return nil
            }
        } else {
            if startingMeasure < 1.0 {
                if startingMeasure < 0 {
                    iconType = IconType.TOO_EARLY
                } else {
                    iconType = IconType.START
                }
                if currentLocation == nil {
                    currentLocation = journeyDisplay.route.getStartingPoint()
                    currentBearing = 0
                    currentDistance = 0
                    currentTimeDiff = 0
                }
            } else {
                iconType = IconType.NORMAL
            }
        }
        if currentLocation != nil {
            let args = LocatorArgs(journeyDisplay: journeyDisplay, currentLocation: currentLocation!, currentDirection: currentBearing!, currentDistance: currentDistance!, currentTimeDiff: currentTimeDiff!, onRoute: onRoute, isReporting: isReporting, isReported: isReported, startMeasure: startingMeasure, disposition: disposition, iconType: iconType)
            return args
        }
        return nil
    }
    
    func getJourneyLocators(journeyDisplays : [JourneyDisplay]) -> [LocatorArgs] {
        var locators : [LocatorArgs] = [LocatorArgs]()
        var highlighted : [LocatorArgs] = [LocatorArgs]()
        var postingRoute : JourneyDisplay? = nil
        var placed = 0
        for jd in journeyDisplays {
            if jd.isPathVisible() && jd.route.isJourney() {
                if jd.route.isReporting() {
                    postingRoute = jd
                } else {
                    if !jd.isFinished() {
                        if jd.isPathHighlighted() {
                            let locarg = getJourneyLocator(jd, disposition: Disposition.HIGHLIGHT)
                            if locarg != nil {
                                highlighted.append(locarg!)
                            }
                        } else {
                            let locarg = getJourneyLocator(jd, disposition: Disposition.NORMAL)
                            if locarg != nil {
                                locators.append(locarg!)
                            }
                        }
                        placed += 1
                    }
                }
            }
        }
        locators.extend(highlighted)
        if postingRoute != nil {
            let locarg = getJourneyLocator(postingRoute!, disposition: Disposition.NORMAL)
            if locarg != nil {
                locators.append(locarg!)
            }
        }
        return locators
    }
    
    // Returns the list with the hightlighted patterns last
    func getRoutePatterns(journeyDisplays : [JourneyDisplay]) -> [PatternArgs] {
        var patterns : [String:JourneyPattern] = [String:JourneyPattern]()
        var highlighted : [String:JourneyPattern] = [String:JourneyPattern]()
        for jd in journeyDisplays {
            if jd.isPathVisible() {
                if jd.isPathHighlighted() {
                    for p in jd.route.getJourneyPatterns() {
                        if p.isReady() {
                            highlighted[p.id] = p
                        }
                    }
                } else {
                    for p in jd.route.getJourneyPatterns() {
                        if p.isReady() {
                            patterns[p.id] = p
                        }
                    }
                }
            }
        }
        var args = [PatternArgs]()
        for p in patterns.values.array {
            args.append(PatternArgs(journeyPattern: p, disposition: Disposition.NORMAL))
        }
        for p in highlighted.values.array {
            args.append(PatternArgs(journeyPattern: p, disposition: Disposition.HIGHLIGHT))
        }
        return args
    }

}
