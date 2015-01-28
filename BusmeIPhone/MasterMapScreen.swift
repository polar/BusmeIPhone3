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

public class MasterMapScreen : UIViewController, MKMapViewDelegate {
    public var mapView : MKMapView!
    public var activityView : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    public var activityBarButton : UIBarButtonItem!
    public var titleView : UIBarButtonItem!
    public var menuButton : UIBarButtonItem!
    public var master : Master!
    
    var syncProgressDialogController : SyncProgressDialogController!
    
    var routesView : RoutesView?
    var tabButton : TabButton?
    

    public var api : BuspassApi!
    public var masterController : MasterController!
    public var fgBannerPresentationController : FGBannerPresentController!
    public var fgMarkerPresentationController : FGMarkerPresentController!
    public var fgMasterMessagePresentationController : FGMasterMessagePresentController!
    var masterOverlay : MasterOverlay!
    
    public func setMasterController(masterController : MasterController) {
        self.masterController = masterController
        self.api = masterController.api
        self.master = masterController.master
        self.syncProgressDialogController = SyncProgressDialogController(api: api, master: master)
        self.fgBannerPresentationController = FGBannerPresentController(masterMapScreen: self)
        self.fgMarkerPresentationController = FGMarkerPresentController(masterMapScreen: self)
        self.fgMasterMessagePresentationController = FGMasterMessagePresentController(masterMapScreen: self)
        self.masterOverlay = MasterOverlay(master: masterController.master, masterController: masterController)
    }
    
    override public func viewDidLoad() {
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
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent) {
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
    
    public func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(MarkerAnnotation) {
            let maview = MarkerAnnotationView(markerAnnotation: annotation as MarkerAnnotation)
            maview.masterMapScreen = self
            return maview
        }
        return nil
    }
    
    public func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let overlayView =  MasterOverlayView(overlay: overlay as MasterOverlay, mapView: mapView, masterController: masterController)
        overlayView.setCenterAndZoom()
        return overlayView
    }
}