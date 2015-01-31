//
//  MasterMapScreen.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/13/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import MapKit

class MasterMapScreen : UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {
    var mapView : MKMapView!
    var activityView : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    var activityBarButton : UIBarButtonItem!
    var titleView : UIBarButtonItem!
    var menuButton : UIBarButtonItem!
    var master : Master!
    
    var syncProgressDialogController : SyncProgressDialogController!
    
    var routesView : RoutesView?
    var tabButton : TabButton?
    

    var api : BuspassApi!
    var masterController : MasterController!
    var fgBannerPresentationController : FGBannerPresentController!
    var fgMarkerPresentationController : FGMarkerPresentController!
    var fgMasterMessagePresentationController : FGMasterMessagePresentController!
    var masterOverlay : MasterOverlay!
    var locationManager : CLLocationManager!
    
    func setMasterController(masterController : MasterController) {
        self.masterController = masterController
        self.api = masterController.api
        self.master = masterController.master
        self.syncProgressDialogController = SyncProgressDialogController(api: api, master: master)
        self.fgBannerPresentationController = FGBannerPresentController(masterMapScreen: self)
        self.fgMarkerPresentationController = FGMarkerPresentController(masterMapScreen: self)
        self.fgMasterMessagePresentationController = FGMasterMessagePresentController(masterMapScreen: self)
        self.masterOverlay = MasterOverlay(master: masterController.master, masterController: masterController)
        self.locationManager = CLLocationManager()
        if locationManager.respondsToSelector("requestWhenInUseAuthorization") {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    var splashView : UIImageView?
    func setSplashView(splashScreen : SplashScreen) {
        self.splashView = UIImageView(frame: UIScreen.mainScreen().bounds)
        self.splashView!.image = splashScreen.image
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Map
        self.mapView = MKMapView(frame: UIScreen.mainScreen().bounds)
        self.view = mapView
        self.mapView.delegate = self
        
        // Navbar
        activityView.hidesWhenStopped = true
        self.activityBarButton = UIBarButtonItem(customView: activityView)
        self.navigationItem.rightBarButtonItem = activityBarButton
        
        self.menuButton = UIBarButtonItem(title: "Menu", style: UIBarButtonItemStyle.Plain, target: self, action: "openMenu")
        self.navigationItem.leftBarButtonItem = menuButton
        self.navigationItem.title = master.name!
        
        self.tabButton = TabButton()
        self.routesView = RoutesView(masterController: masterController, masterMapScreen: self, tabButton: tabButton!)
        view.addSubview(routesView!.view)
        view.addSubview(tabButton!)
        view.autoresizesSubviews = false
        routesView!.viewWillAppear(false)
        mapView.addOverlay(masterOverlay)
        mapView.showsUserLocation = true
        initializeTouches()
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Touches
    
    func initializeTouches() {
        var dtapR = UITapGestureRecognizer(target: self, action: "onDoubleTap:")
        dtapR.numberOfTapsRequired = 2
        dtapR.numberOfTouchesRequired = 2
        dtapR.delegate = self
        view.addGestureRecognizer(dtapR)
        
        var tapR = UITapGestureRecognizer(target: self, action: "onClick:")
        tapR.numberOfTapsRequired = 1
        tapR.numberOfTouchesRequired = 1
        tapR.delegate = self
        view.addGestureRecognizer(tapR)
        
        var pressR = UILongPressGestureRecognizer(target: self, action: "onPress:")
        pressR.delegate = self
        view.addGestureRecognizer(pressR)
    }
    
    func onDoubleTap(genstureRecognizer: UIGestureRecognizer) {
        if locationManager.location != nil {
            setCenter(locationManager.location!.coordinate, animated: true)
        }
    }
    
    func onClick(gestureRecognizer : UIGestureRecognizer) {
        if BLog.DEBUG { BLog.logger.debug("onClick\(gestureRecognizer.locationInView(mapView))") }
    }
    
    func onPress(gestureRecognizer : UIGestureRecognizer) {
        if BLog.DEBUG { BLog.logger.debug("onPress\(gestureRecognizer.locationInView(mapView))") }
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if routesView != nil && routesView!.view != nil {
            if mapView != nil {
                let point = touch.locationInView(mapView)
                let result = !CGRectContainsPoint(routesView!.view!.frame, point)
                return result
            } else {
                return true
            }
        } else {
            return true
        }
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
        if (motion == UIEventSubtype.MotionShake) {
            routesView?.toggleSlide()
            routesView?.reload()
        }
    }

    func openMenu() {
        let menuScreen = MasterMainMenu().initWithMasterController(masterController!)
        navigationController?.pushViewController(menuScreen, animated: true)
    }
    
    func setCenter(point : CLLocationCoordinate2D, animated : Bool ) {
        mapView.setCenterCoordinate(point, animated: animated)
    }
    
    func addMarkerAnnotation(annotation : MarkerAnnotation) {
        mapView.addAnnotation(annotation)
    }
    
    func removeMarkerAnnotation(annotation : MarkerAnnotation) {
        mapView.removeAnnotation(annotation)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(MarkerAnnotation) {
            let maview = MarkerAnnotationView(markerAnnotation: annotation as MarkerAnnotation)
            maview.masterMapScreen = self
            return maview
        } else if annotation.isKindOfClass(JourneyLocationAnnotation) {
            let jaview = JourneyLocationAnnotationView(journeyLocationAnnotation: annotation as JourneyLocationAnnotation)
            jaview.masterMapScreen = self
        } else {
            if BLog.DEBUG { BLog.logger.debug("userLocationView?") }
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let overlayView =  MasterOverlayView(overlay: overlay as MasterOverlay, mapView: mapView, masterController: masterController)
        overlayView.setCenterAndZoom()
        return overlayView
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        if BLog.DEBUG { BLog.logger.debug("userLocation\(newLocation.coordinate)") }
        
    }
}