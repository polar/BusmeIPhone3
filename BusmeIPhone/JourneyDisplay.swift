//
//  JourneyDisplay.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/9/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class JourneyDisplay {
    public var route : Route
    public var journeyDisplayController : JourneyDisplayController
    
    public init(jdc : JourneyDisplayController, route : Route) {
        self.journeyDisplayController = jdc
        self.route = route
    }
}