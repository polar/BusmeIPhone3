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

class PatternArgs {
    var journeyPattern : JourneyPattern!
    let disposition : Int
    init (journeyPattern: JourneyPattern, disposition : Int) {
        self.journeyPattern = journeyPattern
        self.disposition = disposition
    }
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}


class RouteAndLocationsMapLayer {
    
    unowned var api : BuspassApi
    unowned var journeyDisplayController : JourneyDisplayController
    unowned var journeyLocationPoster : JourneyLocationPoster
    unowned var journeyVisibilityController : JourneyVisibilityController
    
    init(api : BuspassApi, journeyVisibilityController: JourneyVisibilityController, journeyDisplayController : JourneyDisplayController, journeyLocationPoster : JourneyLocationPoster ) {
        self.api = api
        self.journeyDisplayController = journeyDisplayController
        self.journeyLocationPoster = journeyLocationPoster
        self.journeyVisibilityController = journeyVisibilityController
    }
    
    func getCurrentLocation() -> Location? {
        return journeyLocationPoster.getCurrentLocation()
    }
    
    func getJourneyLocator(journeyDisplay : JourneyDisplay, disposition : Int) -> LocatorArgs? {
        if journeyDisplay.route.getJourneyPatterns().isEmpty || !journeyDisplay.route.getJourneyPatterns()[0].isReady() {
            // We need a path, it may have not come in yet.
            return nil
        }
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
        let state = journeyVisibilityController.getCurrentState()
        if state.state == state.S_VEHICLE {
            let jd = state.selectedRoute!
            let pats = jd.route.getJourneyPatterns()
            if pats.count > 0 && pats[0].isReady() {
                let locarg = getJourneyLocator(jd, disposition: Disposition.TRACK)
                if locarg != nil {
                    locators.append(locarg!)
                }
            }
        } else {
            for jd in journeyDisplays {
                if selected(state, journeyDisplay: jd) && jd.isPathVisible() && jd.route.isJourney() {
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
    
    private func selected(state : VisualState, journeyDisplay : JourneyDisplay) -> Bool {
        return (state.selectedRoutes.count == 0 || state.selectedRoutes.member(journeyDisplay) != nil)
    }
    
    // Returns the list with the hightlighted patterns last
    func getRoutePatterns(journeyDisplays : [JourneyDisplay]) -> [PatternArgs] {
        var args = [PatternArgs]()
        var patterns : [String:JourneyPattern] = [String:JourneyPattern]()
        var highlighted : [String:JourneyPattern] = [String:JourneyPattern]()
        let state = journeyVisibilityController.getCurrentState()
        if state.state == state.S_VEHICLE {
            let jd = state.selectedRoute!
            let pats = jd.route.getJourneyPatterns()
            if pats.count > 0 && pats[0].isReady() {
                let pat = PatternArgs(journeyPattern: pats[0], disposition: Disposition.TRACK)
                args.append(pat)
            }
        } else {
            for jd in journeyDisplays {
                if selected(state, journeyDisplay: jd) && jd.isPathVisible() {
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
        }
        for p in patterns.values.array {
            args.append(PatternArgs(journeyPattern: p, disposition: Disposition.NORMAL))
        }
        for p in highlighted.values.array {
            args.append(PatternArgs(journeyPattern: p, disposition: Disposition.HIGHLIGHT))
        }
        return args
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }

}
