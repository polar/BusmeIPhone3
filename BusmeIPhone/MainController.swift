//
//  MainController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class MainController {
    public var api : DiscoverApiVersion1
    public var discoverController : DiscoverController
    
    
    public init(api : DiscoverApiVersion1) {
        self.api = api
        self.discoverController = DiscoverController()
    }
    
}