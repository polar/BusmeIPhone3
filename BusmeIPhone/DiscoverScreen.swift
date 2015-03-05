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

let APP_VERSION = "0.1.0"
let PLATFORM_NAME = "iOS"

class DiscoverScreen : UIViewController, MKMapViewDelegate, UIAlertViewDelegate, BuspassEventListener {
    let mapView : MKMapView!
    var discoverApi : DiscoverApiVersion1
    var mainController : MainController
    var activityView : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var activityBarButton : UIBarButtonItem!
    var titleView : UIBarButtonItem!
    var menuButton : UIBarButtonItem!

    var discoverMenuScreen : DiscoverMenu?
    var splashView : UIImageView?
    var directionLabelView : UILabel?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(mainController : MainController, splashScreen : SplashScreen?) {
        self.mainController = mainController
        self.discoverApi = mainController.discoverController.api
        super.init(nibName: nil, bundle: nil);
        
        // Navbar
        activityView.hidesWhenStopped = true
        self.activityBarButton = UIBarButtonItem(customView: activityView)
        self.navigationItem.rightBarButtonItem = activityBarButton
        
        self.menuButton = UIBarButtonItem(title: "Menu", style: UIBarButtonItemStyle.Plain, target: self, action: "openMenu")
        self.navigationItem.leftBarButtonItem = menuButton
        if mainController.api.operationMode == OPM_TEST {
            self.navigationItem.title = "Test Platforms"
        } else {
            self.navigationItem.title = "Busme!"
        }
        

        self.mapView = MKMapView(frame: UIScreen.mainScreen().bounds)
        //self.view = mapView
        self.mapView.delegate = self
        if splashScreen != nil {
            self.splashView = UIImageView(frame: UIScreen.mainScreen().bounds)
            self.splashView!.image = splashScreen!.image
        }
        
        directionLabelView = UILabel(frame: CGRect())
        var style : NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as NSMutableParagraphStyle
        style.lineBreakMode = NSLineBreakMode.ByWordWrapping
        style.alignment = NSTextAlignment.Center
        
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 1
        shadow.shadowColor = UIColor.lightGrayColor()
        shadow.shadowOffset = CGSize(width: 1, height: 1)

        let attributes = [NSParagraphStyleAttributeName: style, NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSShadowAttributeName: shadow ]
        directionLabelView?.attributedText = NSAttributedString(string: "Scroll, Zoom, and Long Press to discover Busme Transit Sytems in that area.\nThen single tap to select. Tapping where there are none will lead you to a selection page of the ones that appeared.", attributes: attributes)
        directionLabelView?.numberOfLines = 0
        directionLabelView?.backgroundColor = UIColor(red: 0.5, green: 0, blue: 0.2, alpha: 0.6)
        directionLabelView?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        registerForEvents()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = mapView
        view.addSubview(directionLabelView!)
        directionLabelView!.userInteractionEnabled = false
            
        var direct = CGRect(origin: UIScreen.mainScreen().bounds.origin, size: UIScreen.mainScreen().bounds.size)
        direct.size.height = direct.height * 0.30
        direct.offset(dx: 0, dy: navigationController!.navigationBar.frame.origin.y + navigationController!.navigationBar.frame.size.height)
        direct.inset(dx: direct.width * 0.05, dy: 10)
        directionLabelView!.frame = direct
            
        initializeTouches()
        
        let eventData = DiscoverEventData()
        discoverApi.bgEvents.postEvent("Search:init", data: eventData)
        
        if splashView != nil {
            view.addSubview(splashView!)
            view.bringSubviewToFront(splashView!)
            navigationController?.navigationBarHidden = true

            UIView.animateWithDuration(10.0,
                animations: {
                    self.splashView!.alpha = 0
                    self.navigationController?.view.alpha = 1
                },
                completion: {(finished) in
                    self.splashView!.removeFromSuperview()
                    self.splashView = nil
                    self.navigationController?.navigationBarHidden = false
            })

            
        }
    }
    
    func registerForEvents() {
        discoverApi.uiEvents.registerForEvent("Search:Init:return", listener: self)
        discoverApi.uiEvents.registerForEvent("Search:Discover:return", listener: self)
        discoverApi.uiEvents.registerForEvent("Search:Find:return", listener: self)
    }
    
    func unregisterForEvents() {
        discoverApi.uiEvents.unregisterForEvent("Search:Init:return", listener: self)
        discoverApi.uiEvents.unregisterForEvent("Search:Discover:return", listener: self)
        discoverApi.uiEvents.unregisterForEvent("Search:Find:return", listener: self)
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
        let loc = mainController.configurator.getLastLocation()
        if loc != nil {
            performDiscoverFromGeoPoint(true, geoPoint: loc!)
        }
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
        mapView.addGestureRecognizer(tapR)
        
        var pressR = UILongPressGestureRecognizer(target: self, action: "onPress:")
        mapView.addGestureRecognizer(pressR)
    }

    
    func onClick(gestureRecognizer : UIGestureRecognizer) {
        performFind(gestureRecognizer)
    }
    
    func onPress(gestureRecognizer : UIGestureRecognizer) {
        performDiscover(gestureRecognizer)
    }
    
    func openMenu() {
        let menuScreen = DiscoverMenu().initWithDiscoverScreen(self, mainController: mainController)
        navigationController?.pushViewController(menuScreen, animated: true)
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
    
    func performDiscoverFromGeoPoint(showDialog : Bool, geoPoint: GeoPoint) {
        if !discoverInProgress {
            self.discoverInProgress = true
            
            let coord = CLLocationCoordinate2D(latitude: geoPoint.getLatitude(), longitude: geoPoint.getLongitude())
            mapView.centerCoordinate = coord
            let mapRegion = mapView.region
            let buf = mapRegion.span.latitudeDelta / GeoCalc.LAT_PER_FOOT
            performDiscoverFromLoc(true, loc: coord, buf: buf)
        }
    }
    
    func performDiscoverFromLoc(showDialog : Bool, loc : CLLocationCoordinate2D, buf : Double) {
        var dialog : UIAlertView?
        if showDialog {
            dialog = searchDialog("Searching ....", message: "Searching near location \(loc.getLongitude()), \(loc.getLatitude())")
        }
        
        let eventData = DiscoverEventData(loc: loc, buf: buf, dialog: dialog)
        discoverApi.bgEvents.postEvent("Search:discover", data: eventData)
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
        discoverApi.bgEvents.postEvent("Search:find", data: eventData)
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
    
    deinit {
            if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("Dealloc") }
            discoverMenuScreen = nil
    }
}


