//
//  FGMarkerPresentController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/13/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreGraphics

class FGMarkerPresentController : BuspassEventListener {
    
    weak var api : BuspassApi!
    weak var masterMapScreen : MasterMapScreen!
    weak var masterController : MasterController!
    
    var currentMarkerMessageController : MarkerMessageViewController?
    
    init(masterMapScreen : MasterMapScreen) {
        self.masterMapScreen = masterMapScreen
        self.masterController = masterMapScreen.masterController
        self.api = masterMapScreen.api
        registerForEvents()
        
    }
    
    func registerForEvents() {
        api.uiEvents.registerForEvent("MarkerPresent:display", listener: self)
        api.uiEvents.registerForEvent("MarkerPresent:dismiss", listener: self)
        api.uiEvents.registerForEvent("MarkerPresent:webDisplay", listener: self)
    }
    
    
    func unregisterForEvents() {
        api.uiEvents.unregisterForEvent("MarkerPresent:display", listener: self)
        api.uiEvents.unregisterForEvent("MarkerPresent:dismiss", listener: self)
        api.uiEvents.unregisterForEvent("MarkerPresent:webDisplay", listener: self)
    }
    
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventData = event.eventData as? MarkerEventData
        if eventData != nil {
            if event.eventName == "MarkerPresent:display" {
                presentMarker(eventData!);
            } else if event.eventName == "MarkerPresent:dismiss" {
                abandonMarker(eventData!);
            } else if event.eventName == "MarkerPresent:webDisplay" {
                onWebDisplay(eventData!);
            }
        }
    }
    
    private var currentMarkers : [String:MarkerAnnotation] = [String:MarkerAnnotation]()
    func presentMarker(eventData : MarkerEventData) {
        let markerInfo = eventData.markerInfo
        let annotation = MarkerAnnotation(markerInfo: markerInfo)
        currentMarkers[markerInfo.id] = annotation
        masterMapScreen.addMarkerAnnotation(annotation)
    }
    
    func abandonMarker(eventData : MarkerEventData) {
        let markerInfo = eventData.markerInfo
        let annotation = currentMarkers[markerInfo.id]
        if annotation != nil {
            masterMapScreen.removeMarkerAnnotation(annotation!)
        }
    }
    
    // Called from the MarkerMessageViewController when it should go away, 
    // after a displayWebPage
    func removeCurrent(viewController : MarkerMessageViewController) {
        if currentMarkerMessageController === viewController {
            self.currentMarkerMessageController = nil
        }
    }
    
    func dismissMessage(markerInfo: MarkerInfo) {
        if currentMarkerMessageController != nil {
            currentMarkerMessageController!.dismiss()
        }
        self.currentMarkerMessageController = nil
    }
    
    func displayMessage(markerInfo: MarkerInfo) {
        if currentMarkerMessageController != nil {
            currentMarkerMessageController!.dismiss()
        }
        currentMarkerMessageController =  MarkerMessageViewController(masterMapScreen: masterMapScreen!, markerInfo: markerInfo)
        currentMarkerMessageController!.display()
    }
    
    func onWebDisplay(eventData : MarkerEventData) {
        if currentMarkerMessageController != nil {
            currentMarkerMessageController?.displayWebPage(eventData.thruUrl)
        }
    }
}
