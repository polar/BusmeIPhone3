//
//  JourneyDisplaySelectionController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/9/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation


class JourneyDisplaySelectionController {
    var api : BuspassApi
    var journeyDisplayController : JourneyDisplayController
    
    init(api : BuspassApi, journeyDisplayController : JourneyDisplayController) {
        self.api = api
        self.journeyDisplayController = journeyDisplayController
    }
    
}