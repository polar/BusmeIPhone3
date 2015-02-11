//
//  EventsApi.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/15/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

protocol EventsApi : class{
    var uiEvents : BuspassEventDistributor { get }
    var bgEvents : BuspassEventDistributor { get }
}