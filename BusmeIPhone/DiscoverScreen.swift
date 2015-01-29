//
//  MainMapScreen.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/13/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit
import MapKit

let APP_VERSION = "1.0.0"
let PLATFORM_NAME = "iOS"

class DiscoverScreen : UIViewController, MKMapViewDelegate, UIAlertViewDelegate, BuspassEventListener {
    let mapView : MKMapView!
    var api : DiscoverApiVersion1
    var mainController : MainController
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(mainController : MainController) {
        self.mainController = mainController
        self.api = mainController.discoverController.api
        super.init(nibName: nil, bundle: nil);
        
        self.mapView = MKMapView(frame: UIScreen.mainScreen().bounds)
        self.view = mapView
        self.mapView.delegate = self
        
        registerForEvents()
        initializeTouches()
    }
    
    // This doesn't get called.
    override func viewDidLoad() {
        super.viewDidLoad()
        let eventData = DiscoverEventData()
        mainController.discoverController.api.bgEvents.postEvent("Search:init", data: eventData)
    }
    
    func registerForEvents() {
        mainController.discoverController.api.uiEvents.registerForEvent("Search:Init:return", listener: self)
        mainController.discoverController.api.uiEvents.registerForEvent("Search:Discover:return", listener: self)
        mainController.discoverController.api.uiEvents.registerForEvent("Search:Find:return", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventName = event.eventName
        let eventData = event.eventData as? DiscoverEventData
        if eventData != nil {
            if eventName == "Search:Init:return" {
                onInitReturn(eventData!)
            } else if eventName == "Search:Discover:return" {
                onDiscoverReturn(eventData!)
            } else if eventName == "Search:Find:return" {
                onFindReturn(eventData!)
            }
        }
    }
    
    func onInitReturn(eventData : DiscoverEventData) {
        
    }
    
    func onDiscoverReturn(eventData : DiscoverEventData) {
        if eventData.dialog != nil {
            eventData.dialog?.dismissWithClickedButtonIndex(0, animated: true)
        }
        if eventData.masters != nil {
            let masters = eventData.masters!
            for master in masters {
                let site = BusmeSiteImpl(master: master)
                mapView.addOverlay(site)
            }
        }
        self.discoverInProgress = false
    }
    
    // Touches
    
    func initializeTouches() {
        var tapR = UITapGestureRecognizer(target: self, action: "onClick:")
        tapR.numberOfTapsRequired = 1
        tapR.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapR)
        
        var pressR = UILongPressGestureRecognizer(target: self, action: "onPress:")
        view.addGestureRecognizer(pressR)
    }

    
    func onClick(gestureRecognizer : UIGestureRecognizer) {
        performFind(gestureRecognizer)
    }
    
    func onPress(gestureRecognizer : UIGestureRecognizer) {
        performDiscover(gestureRecognizer)
    }
    
    // Dialogs
    
    func searchDialog(title : String, message : String) -> UIAlertView {
        let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil)
        alertView.show()
        return alertView
    }
    
    
    func errorDialog(title : String, message : String) -> UIAlertView {
        let alertView = UIAlertView(title: title, message: message, delegate: self, cancelButtonTitle: "OK")
        alertView.show()
        return alertView
    }
    
    // UIAlertViewDelegate
    
    func alertView(alertView: UIAlertView, willDismissWithButtonIndex buttonIndex: Int) {
        self.discoverInProgress = false
    }
    
    // Discover
    
    var discoverInProgress : Bool = false
    
    func performDiscover(gestureRecognizer : UIGestureRecognizer ) {
        if !discoverInProgress {
            self.discoverInProgress = true
            
            let cgpoint = gestureRecognizer.locationInView(mapView)
            let loc = mapView.convertPoint(cgpoint, toCoordinateFromView: mapView)
            let mapRegion = mapView.region
            let buf = mapRegion.span.latitudeDelta / GeoCalc.LAT_PER_FOOT
            performDiscoverFromLoc(true, loc: loc, buf: buf)
        }
    }
    
    func performDiscoverFromLoc(showDialog : Bool, loc : CLLocationCoordinate2D, buf : Double) {
        var dialog : UIAlertView?
        if showDialog {
            dialog = searchDialog("Searching ....", message: "Searching near location \(loc.getLongitude()), \(loc.getLatitude())")
        }
        
        let eventData = DiscoverEventData(loc: loc, buf: buf, dialog: dialog)
        mainController.discoverController.api.bgEvents.postEvent("Search:discover", data: eventData)
    }
    
    // Find
    
    func performFind(gestureRecognizer : UIGestureRecognizer ) {
        if !discoverInProgress {
            self.discoverInProgress = true
            
            let cgpoint = gestureRecognizer.locationInView(mapView)
            let loc = mapView.convertPoint(cgpoint, toCoordinateFromView: mapView)
            performFindFromLoc(loc)
        }
    }
    
    func performFindFromLoc(loc : CLLocationCoordinate2D) {
        let eventData = DiscoverEventData(loc: loc, dialog: nil)
        mainController.discoverController.api.bgEvents.postEvent("Search:find", data: eventData)
    }
    
    func onFindReturn(eventData : DiscoverEventData) {
        if eventData.error != nil {
            if (BLog.WARN) {BLog.logger.warn("error from find \(eventData.error?.reasonPhrase)")}
            errorDialog("Error", message: eventData.error!.reasonPhrase)
        }
        self.discoverInProgress = false
        if eventData.master != nil {
            let master = eventData.master!
            doMasterInit(master)
        } else {
            let discoverController = mainController.discoverController
            if !discoverController.getMasters().isEmpty {
                let mastersTableScreen = MastersTableScreen()
                mastersTableScreen.setDiscoverController(discoverController)
                mastersTableScreen.setMainController(mainController)
                self.navigationController?.pushViewController(mastersTableScreen, animated: true)
            }
        }
    }
    
    func doMasterInit(master : Master) {
        self.navigationController?.popViewControllerAnimated(true)
        let eventData = MainEventData(master : master)
        mainController.api.uiEvents.postEvent("Main:Discover:return", data: eventData)
    }
    
    // MKOverlayRenderer
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if (overlay is BusmeSite) {
            return BusmeSiteView(overlay: overlay)
        }
        // Should never get here
        return nil
    }
    
}



