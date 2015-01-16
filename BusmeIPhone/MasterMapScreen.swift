//
//  MasterMapScreen.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/13/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit
import MapKit

public class MasterMapScreen : UIViewController, MKMapViewDelegate {
    public var mapView : MKMapView!
    public var activityView : UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    public var activityBarButton : UIBarButtonItem!
    public var titleView : UIBarButtonItem!
    public var menuButton : UIBarButtonItem!
    public var master : Master!
    

    public var api : BuspassApi!
    public var masterController : MasterController!
    public var fgBannerPresentationController : FGBannerPresentController!
    
    public func setMasterController(masterController : MasterController) {
        self.masterController = masterController
        self.api = masterController.api
        self.master = masterController.master
        self.fgBannerPresentationController = FGBannerPresentController(masterMapScreen: self)
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
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func openMenu() {
        let menuScreen = MasterMainMenu().initWithMasterController(masterController!)
        navigationController?.pushViewController(menuScreen, animated: true)
    }
}