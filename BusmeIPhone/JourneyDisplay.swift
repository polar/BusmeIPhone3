//
//  JourneyDisplay.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/9/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

struct JourneyIcon {
    
    static let imageNames = [
        "route_icon.png",
        "route_icon_active.png",
        "purple_dot_icon.png",
        "blue_circle_icon.png",
        "green_arrow_icon.png",
        "blue_arrow_icon.png",
        "bus_icon_active.png",
        "red_arrow_icon.png"
    ]
    
    static let ROUTE_ICON = 0
    static let ROUTE_ICON_ACTIVE = 1
    static let PURPLE_DOT_ICON = 2
    static let BLUE_CIRCLE_ICON = 3
    static let GREEN_ARROW_ICON = 4
    static let BLUE_ARROW_ICON = 5
    static let BUS_ICON_ACTIVE = 6
    static let RED_ARROW_ICON = 7
    
    static var imageCache : [String:UIImage] = [:]
    
    static func getIconImage(index : Int) -> UIImage? {
        let imageName = imageNames[index]
        var image = imageCache[imageName]
        if image == nil {
            image = UIImage(named: imageNames[index])
            if image != nil {
                imageCache[imageName] = image
            }
        }
        return image
    }
}

protocol OnVisibilityListener : class {
    func onChange(which : String, value : Bool)
}

class JourneyDisplay {
    var route : Route
    
    private var nameVisible : Bool = false
    private var nameHighlighted : Bool = false
    private var pathVisible : Bool = false
    private var pathHighlighted : Bool = false
    private var tracking : Bool = false
    
    private weak var onVisibilityListener : OnVisibilityListener?
    private unowned var journeyDisplayController : JourneyDisplayController
    
    init(journeyDisplayController : JourneyDisplayController, route : Route) {
        self.journeyDisplayController = journeyDisplayController
        self.route = route
    }
    
    func distanceFromRoute(point : GeoPoint) -> Double? {
        let paths = route.getPaths()
        var distance = 10000000000.00
        if paths.count > 0 {
            for path in paths {
                let dist = GeoPathUtils.offPath(path, point: point)
                distance = min(dist, distance)
            }
            return distance
        } else {
            return nil
        }
    }
    
    func currentDistanceFromRoute() -> (GeoPoint, Double)? {
        let point = journeyDisplayController.currentLocation
        if point != nil {
            let dist = distanceFromRoute(point!)
            return (point!, dist!)
        } else {
            return nil
        }
    }
    
    func distanceFromCurrentLocation() -> (GeoPoint, DGeoPoint)? {
        let loc = route.lastKnownLocation
        let time = route.lastKnownTime
        let dist = route.lastKnownDistance
        let point = journeyDisplayController.currentLocation
        if point != nil {
            var distance = route.lastKnownDistance
            var selected : DGeoPoint?
            if distanceFromRoute(point!) < 60 {
                let dpoints = GeoPathUtils.whereOnPath(route.getPaths()[0], buffer: route.distanceTolerance, point: point!)
                for dp in dpoints {
                    if dp.distance > route.lastKnownDistance {
                        if dp.distance <= distance {
                            selected = dp
                        }
                    }
                }
            }
            if selected != nil {
                return (point!, selected!)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func isStartingJourney() -> Bool {
        return route.isStartingJourney()
    }
    
    func isFinished() -> Bool {
        return route.isFinished()
    }
    
    func isActive() -> Bool {
        return route.isActiveJourney() && !isFinished() || isStartingJourney()
    }
    
    func isNameVisible() -> Bool {
        return nameVisible && !route.isFinished()
    }
    
    func isPathVisible() -> Bool {
        return pathVisible
    }
    
    func isHidden() -> Bool {
        return !pathVisible
    }
    
    private var geoRect : GeoRect?
    func getGeoRect() -> GeoRect {
        if geoRect != nil {
            return geoRect!
        }
        var result = GeoRect(left: 0.0, top: 0.0, right: 0.0, bottom: 0.0)
        for path in route.getPaths() {
           let pathRect = GeoPathUtils.rectForPath(path)
            result = GeoPathUtils.unionGeoRect(result, rect2: pathRect)
        }
        geoRect = result
        return geoRect!
    }
    
    func setPathVisible(visible : Bool) {
        self.pathVisible = visible
        notifyVisibilityListener("path", value: self.pathVisible)
    }
    
    func setPathHidden(hidden : Bool) {
        self.pathVisible = !hidden
        notifyVisibilityListener("path", value: self.pathVisible)
    }
    
    func setNameVisible(visible : Bool) {
        self.nameVisible = visible
        notifyVisibilityListener("name", value: self.nameVisible)
    }
    
    func setNameHidden(hidden : Bool) {
        self.nameVisible = !hidden
        notifyVisibilityListener("name", value: self.nameVisible)
    }
    
    func notifyVisibilityListener(which : String, value : Bool) {
        self.onVisibilityListener?.onChange(which, value: value)
    }
    
    func isTracking() -> Bool {
        return tracking
    }
    
    func isNameHighlighted() -> Bool {
        return nameHighlighted
    }
    func setNameHighlighted( value : Bool) {
        self.nameHighlighted = value
    }
    
    func isPathHighlighted() -> Bool {
        return pathHighlighted
    }
    func setPathHighlighted( value : Bool) {
        self.pathHighlighted = value
    }
    
    func hasActiveJourneys() -> Bool {
        if route.isRouteDefinition() {
            for jd in journeyDisplayController.getJourneyDisplays() {
                if jd.isActive() {
                    if jd.route.code == route.code {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func getIcon() -> Int {
        if route.isRouteDefinition() {
            if hasActiveJourneys() {
                return JourneyIcon.ROUTE_ICON_ACTIVE
            } else {
                return JourneyIcon.ROUTE_ICON
            }
        } else {
            if isNameHighlighted() {
                return JourneyIcon.RED_ARROW_ICON
            } else if (route.isStartingJourney()) {
                return JourneyIcon.PURPLE_DOT_ICON
            } else if route.isNotYetStartingJourney() {
                return JourneyIcon.BLUE_CIRCLE_ICON
            } else if isTracking() {
                return JourneyIcon.GREEN_ARROW_ICON
            } else if route.isActiveJourney() {
                return JourneyIcon.BLUE_ARROW_ICON
            } else {
                return JourneyIcon.BUS_ICON_ACTIVE
            }
        }
    }
    
    func doesInclude(array: [JourneyDisplay], elem: JourneyDisplay?) -> Bool {
        if elem != nil {
            for x in array {
                if (x === elem) {
                    return true
                }
            }
        }
        return false
    }
    
    // This should never be a circular definition.
    
    private var myRouteDefinition : JourneyDisplay?
    func getRouteDefinition() -> JourneyDisplay? {
        if doesInclude(journeyDisplayController.getJourneyDisplays(), elem: myRouteDefinition) {
            return myRouteDefinition
        }
        if route.isJourney() {
            for jd in journeyDisplayController.getJourneyDisplays() {
                if jd.route.isRouteDefinition() {
                    if jd.route.code == route.code {
                        self.myRouteDefinition = jd
                        return jd
                    }
                }
            }
        }
        return nil
    }
    
    func getActiveJourneys() -> [JourneyDisplay] {
        var jds = [JourneyDisplay]()
        if route.isRouteDefinition() {
            for jd in journeyDisplayController.getJourneyDisplays() {
                if jd.isActive() {
                    if jd.route.code == route.code {
                        jds.append(jd)
                    }
                }
            }
        }
        return jds
    }
    
    private func compare(i1 : Double, i2: Double) -> Int {
        if (i1 == i2) {
            return 0
        }
        return i1 < i2 ? -1 : 1
    }
    private func compare(i1 : String, i2: String) -> Int {
        if (i1 == i2) {
            return 0
        }
        return i1 < i2 ? -1 : 1
    }

    
    func compareTo(jd :JourneyDisplay) ->Int {
        if (route.isJourney() && jd.route.isJourney() || !route.isJourney() && !jd.route.isJourney()) {
            let cmp = compare(route.sort!, i2: jd.route.sort!)
            if (cmp == 0) {
                if (route.isJourney() && jd.route.isJourney()) {
                    return compare(Double(route.getStartTime()), i2: Double(jd.route.getStartTime()))
                }
                return compare(route.name!, i2: jd.route.name!)
            } else {
                return cmp
            }
        } else {
            if !route.isJourney() {
                return -1
            } else {
                return 1
            }
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
    
    
}