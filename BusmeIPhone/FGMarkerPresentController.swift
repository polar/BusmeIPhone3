//
//  FGMarkerPresentController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/13/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreGraphics

public class FGMarkerPresentController : BuspassEventListener {
    
    weak var api : BuspassApi!
    weak var masterMapScreen : MasterMapScreen!
    weak var masterController : MasterController!
    
    public init(masterMapScreen : MasterMapScreen) {
        self.masterMapScreen = masterMapScreen
        self.masterController = masterMapScreen.masterController
        self.api = masterMapScreen.api
        registerForEvents()
        
    }
    
    func registerForEvents() {
        api.uiEvents.registerForEvent("MarkerPresent:display", listener: self)
        api.uiEvents.registerForEvent("MarkerPresent:dismiss", listener: self)
    }
    
    
    func unregisterForEvents() {
        api.uiEvents.unregisterForEvent("MarkerPresent:display", listener: self)
        api.uiEvents.unregisterForEvent("MarkerPresent:dismiss", listener: self)
    }
    
    
    public func onBuspassEvent(event: BuspassEvent) {
        let eventData = event.eventData as? MarkerEventData
        if eventData != nil {
            if event.eventName == "MarkerPresent:display" {
                presentMarker(eventData!);
            } else if event.eventName == "MarkerPresent:dismiss" {
                abandonMarker(eventData!);
            }
        }
    }
    
    private var currentMarkers : [String:MarkerAnnotation] = [String:MarkerAnnotation]()
    public func presentMarker(eventData : MarkerEventData) {
        let markerInfo = eventData.markerInfo
        let annotation = MarkerAnnotation(markerInfo: markerInfo)
        currentMarkers[markerInfo.id] = annotation
        masterMapScreen.addMarkerAnnotation(annotation)
    }
    
    public func abandonMarker(eventData : MarkerEventData) {
        let markerInfo = eventData.markerInfo
        let annotation = currentMarkers[markerInfo.id]
        if annotation != nil {
            masterMapScreen.removeMarkerAnnotation(annotation!)
        }
    }
}
