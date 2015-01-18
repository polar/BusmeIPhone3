//
//  RoutesView.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/18/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

class RoutesView : UITableViewController {

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var masterController : MasterController!
    weak var masterMapScreen : MasterMapScreen!
    var backButton : UIButton
    var tabButton : TabButton
    
    init(masterController : MasterController, masterMapScreen : MasterMapScreen, tabButton : TabButton) {
        self.masterController = masterController
        self.masterMapScreen = masterMapScreen
        self.backButton = UIButton()
        self.tabButton = tabButton
        super.init()
        backButton.frame.size = CGSize(width: 50,height: 28)
        backButton.setTitle("< Back", forState: UIControlState.Normal)
        backButton.titleLabel!.adjustsFontSizeToFitWidth = true
        backButton.addTarget(self, action: "onBack", forControlEvents: UIControlEvents.TouchUpInside)
        tabButton.routesView = self
    }
    
    func onBack() {
        masterController.journeyVisibilityController.goBack()
        masterController.api.uiEvents.postEvent("VisibilityChanged", data: MasterEventData())
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        view.addSubview(backButton)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: "onSwipeRight")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        swipeRight.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeRight)
        tableView.rowHeight = 48
        tableView.tableFooterView = UIView()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resizeIt", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
    }
    func resizeIt() {
        
    }
    
    func onSwipeRight() {
        
    }
    
    private var viewIsOut : Bool = false
    private var viewOrigin : CGPoint = CGPoint()

    func slideOut() {
        viewOrigin = view.frame.origin
        UIView.animateWithDuration(1.0, animations: {
            let view = self.view
            let origin = view.frame.origin
            let size = view.frame.size
            view.alpha = 0.0
            view.frame.origin = CGPoint(x: origin.x + origin.x + size.width + 10, y: origin.y)
        })
        self.viewIsOut = true
    }
    
    func slideIn() {
        UIView.animateWithDuration(1.0, animations: {
            self.view.frame.origin = self.viewOrigin
        })
        self.viewIsOut = false
    }
    
    func toggleSlide() {
        if viewIsOut {
            slideIn()
        } else {
            slideOut()
        }
    }
}