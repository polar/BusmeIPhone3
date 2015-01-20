//
//  JourneyDisplay.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/9/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public struct JourneyIcon {
    public static let ROUTE_ICON = 1
    public static let ROUTE_ICON_ACTIVE = 2
    public static let PURPLE_DOT_ICON = 3
    public static let BLUE_CIRCLE_ICON = 4
    public static let GREEN_ARROW_ICON = 5
    public static let BLUE_ARROW_ICON = 6
    public static let BUS_ICON_ACTIVE = 7
    public static let RED_ARROW_ICON = 8
}

public protocol OnVisibilityListener {
    func onChange(which : String, value : Bool)
}

public class JourneyDisplay {
    public var route : Route
    
    private var nameVisible : Bool = false
    private var nameHighlighted : Bool = false
    private var pathVisible : Bool = false
    private var pathHighlighted : Bool = false
    private var tracking : Bool = false
    
    private var onVisibilityListener : OnVisibilityListener?
    private var journeyDisplayController : JourneyDisplayController
    
    public init(journeyDisplayController : JourneyDisplayController, route : Route) {
        self.journeyDisplayController = journeyDisplayController
        self.route = route
    }
    
    public func isStartingJourney() -> Bool {
        return route.isStartingJourney()
    }
    
    public func isFinished() -> Bool {
        return route.isFinished()
    }
    
    public func isActive() -> Bool {
        return route.isActiveJourney() && !isFinished() || isStartingJourney()
    }
    
    public func isNameVisible() -> Bool {
        return nameVisible && !route.isFinished()
    }
    
    public func isPathVisible() -> Bool {
        return pathVisible
    }
    
    public func isHidden() -> Bool {
        return !pathVisible
    }
    
    public func setPathVisible(visible : Bool) {
        self.pathVisible = visible
        notifyVisibilityListener("path", value: self.pathVisible)
    }
    
    public func setPathHidden(hidden : Bool) {
        self.pathVisible = !hidden
        notifyVisibilityListener("path", value: self.pathVisible)
    }
    
    public func setNameVisible(visible : Bool) {
        self.nameVisible = visible
        notifyVisibilityListener("name", value: self.nameVisible)
    }
    
    public func setNameHidden(hidden : Bool) {
        self.nameVisible = !hidden
        notifyVisibilityListener("name", value: self.nameVisible)
    }
    
    public func notifyVisibilityListener(which : String, value : Bool) {
        self.onVisibilityListener?.onChange(which, value: value)
    }
    
    public func isTracking() -> Bool {
        return tracking
    }
    
    public func isNameHighlighted() -> Bool {
        return nameHighlighted
    }
    public func setNameHighlighted( value : Bool) {
        self.nameHighlighted = value
    }
    
    public func isPathHighlighted() -> Bool {
        return pathHighlighted
    }
    public func setPathHighlighted( value : Bool) {
        self.pathHighlighted = value
    }
    
    public func hasActiveJourneys() -> Bool {
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
    
    public func getIcon() -> Int {
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
    
    public func doesInclude(array: [JourneyDisplay], elem: JourneyDisplay?) -> Bool {
        if elem != nil {
            for x in array {
                if (x === elem) {
                    return true
                }
            }
        }
        return false
    }
    
    private var myRouteDefinition : JourneyDisplay?
    public func getRouteDefinition() -> JourneyDisplay? {
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
    
    public func getActiveJourneys() -> [JourneyDisplay] {
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

    
    public func compareTo(jd :JourneyDisplay) ->Int {
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
    
    
}