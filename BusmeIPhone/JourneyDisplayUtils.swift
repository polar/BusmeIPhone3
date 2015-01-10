//
//  JourneyDisplayUtils.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/9/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public struct JourneyDisplayUtils {
    
    public static func pathSearch( journeyDisplays : [JourneyDisplay], touchGP : GeoPoint, zoomLevel : Int) -> ([JourneyDisplay], [JourneyDisplay], GeoPoint)? {
        var selectionChanged = false
        
        // 50 Foot Buffer at XL 19 (near mx) and 2000 foot buffer at ZL 1
        let m = Int(2000.0-50.0/(1.0-19.0))
        let buffer = Double(zoomLevel & m + 2000-m)
        var unselected = [JourneyDisplay]()
        var selected = [JourneyDisplay]()
        
        var atLeastOneSelected = false
        for journey in journeyDisplays {
            if journey.isPathVisible() {
                var isSelected = false
                var iPath = 0
                for path in journey.route.getPaths() {
                    if GeoPathUtils.isOnPath(path, buffer: buffer, c3: touchGP) {
                        isSelected = true
                    }
                }
                if isSelected {
                    atLeastOneSelected = true
                    selected.append(journey)
                } else {
                    unselected.append(journey)
                }
            }
        }
        if atLeastOneSelected {
            for journey in unselected {
                selectionChanged = true
                journey.setPathVisible(false)
            }
        }
        if selectionChanged {
            return (selected, unselected, touchGP)
        }
        return nil
    }
    
    public static func	hitPaths(journeyDisplays : [JourneyDisplay], touchRect : Rect, projection : Projection) -> ([JourneyDisplay],[JourneyDisplay]){
        let center = touchRect.center()
        let buffer = max(touchRect.width(), touchRect.height())
        var unselected = [JourneyDisplay]()
        var selected = [JourneyDisplay]()
        for journey in journeyDisplays {
            if journey.isPathVisible() {
                var isSelected = false
                var iPath = 0
                for path in journey.route.getProjectedPaths() {
                    let tpath = ScreenPathUtils.projectedToScreenPath(path, projection: projection)
                    if PathUtils.isOnPath(tpath, rect: touchRect) {
                        isSelected = true
                    }
                    iPath += 1
                }
                if isSelected {
                    selected.append(journey)
                } else {
                    unselected.append(journey)
                }
            }
        }
        return (selected, unselected)
    }
    
    public func hitsRouteLocator(journeyDisplays : [JourneyDisplay], touchPoint : [Point], locatorRect : Rect, projection : Projection) -> JourneyDisplay? {
        for journeyDisplay in journeyDisplays {
            if journeyDisplay.isPathVisible() {
                if journeyDisplay.route.isJourney() {
                    var loc = journeyDisplay.route.lastKnownLocation
                    if loc == nil {
                       let measure = journeyDisplay.route.getStartingMeasure()
                        if 0 < measure && measure < 1.0 {
                            loc = journeyDisplay.route.getStartingPoint()
                        }
                    }
                    if loc != nil {
                        let rect = locatorRect.dup()
                        let screenCoords = projection.toMapPixels(loc!)
                        rect.offsetTo(screenCoords.getX(), screenCoords.getY())
                        if rect.containsXY(touchPoint.getX(), touchPoint.getY()) {
                            return journeyDisplay
                        }
                    }
                }
            }
        }
        return nil
    }
}