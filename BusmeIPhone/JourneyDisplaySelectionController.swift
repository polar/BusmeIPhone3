//
//  JourneyDisplaySelectionController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/9/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation


public class JourneyDisplaySelectionController {
    public var api : BuspassApi
    public var journeyDisplayController : JourneyDisplayController
    
    public init(api : BuspassApi, journeyDisplayController : JourneyDisplayController) {
        self.api = api
        self.journeyDisplayController = journeyDisplayController
    }
    
}