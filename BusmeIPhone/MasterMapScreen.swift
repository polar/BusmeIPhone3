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
    public let mapView : MKMapView!

    public var api : BuspassApi
    public var masterController : MasterController
    public var fgBannerPresentationController : FGBannerPresentController!
    
    public init(masterController : MasterController) {
        self.masterController = masterController
        self.api = masterController.api
        super.init(nibName: nil, bundle: nil);
        
        self.mapView = MKMapView(frame: UIScreen.mainScreen().bounds)
        self.view = mapView
        self.mapView.delegate = self
        self.fgBannerPresentationController = FGBannerPresentController(masterMapScreen: self)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}