//
//  JourneyDisplayUtils.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/9/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public struct JourneyDisplayUtils {
    
    public static func pathSearch( journeyDisplays : [JourneyDisplay], touchGP : GeoPoint, zoomlevel : Double) -> ([JourneyDisplay], [JourneyDisplay], GeoPoint)? {
        var selectionChanged = false
        
        // 50 Foot Buffer at XL 19 (near mx) and 2000 foot buffer at ZL 1
        let m = (2000.0-50.0/(1.0-19.0))
        let buffer = zoomLevel & m + 2000-m
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
    
    public static func	hitPaths(journeyDisplay : [JourneyDisplay], touchRect : GeoRect, projection : Projection) {
        
    }
}