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

public class DiscoverScreen : UIViewController, MKMapViewDelegate {
    public let mapView : MKMapView!
    public var api : DiscoverApi
    public var mainController : MainController
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(mainController : MainController) {
        self.mainController = mainController
        self.api = mainController.api
        super.init(nibName: nil, bundle: nil);
        
        self.mapView = MKMapView(frame: UIScreen.mainScreen().bounds)
        self.view = mapView
        self.mapView.delegate = self
    }
    
    func initializeTouches() {
        var tapR = UITapGestureRecognizer(target: self, action: "onClick")
        tapR.numberOfTapsRequired = 1
        tapR.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapR)
        
        var pressR = UILongPressGestureRecognizer(target: self, action: "onPress")
        view.addGestureRecognizer(pressR)
    }
    
    func onClick(gestureRecognizer : UIGestureRecognizer) {
        
    }
    func onPress(gestureRecognizer : UIGestureRecognizer) {
        performDiscover(gestureRecognizer)
    }
    
    func searchDialog(title : String, message : String) -> UIAlertView {
        let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil)
        alertView.show()
        return alertView
    }
    
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
        mainController.api.bgEvents.postEvent("Search:discover", data: eventData)
    }
    
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
        mainController.api.bgEvents.postEvent("Search:find", data: eventData)
    }
    
    func onFind(eventData : DiscoverEventData) {
        if eventData.error != nil {
            if (BLog.WARN) {BLog.logger.warn("error from find \(eventData.error?.reasonPhrase)")}
            return
        }
        
    }
    
}



