//
//  TestLocationController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 2/26/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class TestLocationController : BuspassEventListener {
    weak var masterMapScreen: MasterMapScreen?
    var selectedRoute : Route?
    
    init(masterMapScreen: MasterMapScreen) {
        self.masterMapScreen = masterMapScreen
        
        registerForEvents()
    }
    
    func registerForEvents() {
        masterMapScreen?.masterController.api.uiEvents.registerForEvent("UpdateProgress", listener: self)
    }
    
    func unregisterForEvents() {
        masterMapScreen?.masterController.api.uiEvents.unregisterForEvent("UpdateProgress", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        if event.eventName == "UpdateProgress" {
            let eventData = event.eventData as? UpdateProgressEventData
            if eventData != nil {
                if eventData!.action == InvocationProgressEvent.U_FINISH {
                    if selectedRoute != nil {
                        let loc = selectedRoute!.lastKnownLocation
                        if loc != nil {
                            let location = Location(name: "\(UtilsTime.current())", lon: loc!.getLongitude(), lat: loc!.getLatitude())
                            location.bearing = GeoCalc.to_degrees(selectedRoute!.lastKnownDirection!)
                            /// TODO: Make this mean something
                            location.speed = 200.0
                            location.source = "TestLocationController"
                            let evd = LocationEventData(location: location)
                            masterMapScreen?.masterController.api.uiEvents.postEvent("LocationChanged", data: evd)
                            return
                        }
                    }
                }
            }
        }
    }
}