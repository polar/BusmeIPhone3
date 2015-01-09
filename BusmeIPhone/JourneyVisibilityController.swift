//
//  JourneyVisibilityController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/9/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class VisualState {
    public let S_ALL = 1
    public let S_ROUTE = 2
    public let S_VEHICLE = 3
    
    public var state : Int = 1
    public var nearBy : Bool = false
    public var onlyActive : Bool = false
    public var selectedRoute : Route?
    public var selectedRouteCode : String?
    public var selectedRouteCodes : [String] = [String]()
    public var selectedRoutes : NSSet = NSSet()
    public var onlySelected : Bool = false
    public var selectedLocations : NSSet = NSSet()
    
    public init() {
        
    }
    
}

public class JourneyVisibilityController {
    public var api : BuspassApi
    public var journeyDisplayController : String?
    
    public var nearByDistance : Int = 500
    public var currentLocation : GeoPoint?
    
    public var stateStack : [VisualState] = [VisualState]()
    
    
}