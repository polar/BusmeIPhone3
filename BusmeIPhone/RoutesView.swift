//
//  RoutesView.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/18/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

class RoutesView : UITableViewController, BuspassEventListener {

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        fatalError("init(nibNameOrNil:bundle:) has not been implemented")
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
        super.init(nibName: nil, bundle: nil)
        //super.init(style: UITableViewStyle.Plain)
        backButton.frame.size = CGSize(width: 50,height: 28)
        backButton.setTitle("< Back", forState: UIControlState.Normal)
        backButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        //backButton.setTitleColor(UIColor.Color(), forState: UIControlState.Normal)
        backButton.titleLabel!.adjustsFontSizeToFitWidth = true
        backButton.addTarget(self, action: "onBack", forControlEvents: UIControlEvents.TouchUpInside)
        tabButton.routesView = self
        registerForEvents()
    }
    
    func registerForEvents() {
        masterController.api.uiEvents.registerForEvent("VisibilityChanged", listener: self)
        masterController.api.uiEvents.registerForEvent("JourneyAdded", listener: self)
        masterController.api.uiEvents.registerForEvent("JourneyRemoved", listener: self)
    }
    
    func unregisterForEvents() {
        masterController.api.uiEvents.unregisterForEvent("VisibilityChanged", listener: self)
        masterController.api.uiEvents.unregisterForEvent("JourneyAdded", listener: self)
        masterController.api.uiEvents.unregisterForEvent("JourneyRemoved", listener: self)
    }
    
    private var journeyDisplays : [JourneyDisplay] = [JourneyDisplay]()
    func onBuspassEvent(event: BuspassEvent) {
        reload()
        
    }
    func reload() {
        let jds  = masterController.journeyDisplayController.getJourneyDisplays()
        //var jds2 = jds.filter({(jd : JourneyDisplay) in jd.isNameVisible() })
        var jds2 = [JourneyDisplay]()
        for (var i = 0; i < jds.count; i++) {
            if jds[i].route.name != nil {
                if jds[i].isNameVisible() {
                    jds2.append(jds[i])
                }
            }
        }
        jds2.sort({(jd1 :JourneyDisplay, jd2 :JourneyDisplay) in jd1.compareTo(jd2) < 0})
        journeyDisplays = jds2
        tableView.reloadData()
    }

    func getJourneyDisplays() -> [JourneyDisplay] {
        return journeyDisplays
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
        
        // Orientation change resize
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "resizeIt:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        // TODO: Do we need to retain this GR?
        let longPressGR = UILongPressGestureRecognizer(target: self, action: "onLongPress:")
        longPressGR.minimumPressDuration = 1.0
        tableView.addGestureRecognizer(longPressGR)
        
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 5, height: 5)
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowRadius = 1.0
        view.layer.masksToBounds = false
    }
    
    func onLongPress(gesture : UIGestureRecognizer) {
        if gesture.state == UIGestureRecognizerState.Began {
            let point = gesture.locationInView(tableView)
            let indexPath = tableView.indexPathForRowAtPoint(point)
            if indexPath != nil {
                let cell = tableView.cellForRowAtIndexPath(indexPath!) as? RouteCell
                if cell != nil {
                    longhit(cell!.journeyDisplay!)
                }
            }
        }
    }
    
    func centerMap(journeyDisplay : JourneyDisplay) {
        let loc = journeyDisplay.route.lastKnownLocation
        if loc != nil {
            let coord = CLLocationCoordinate2D(latitude: loc!.getLatitude(), longitude: loc!.getLongitude())
            masterMapScreen.setCenter(coord, animated: true)
        }
    }
    
    func highlight( jd : JourneyDisplay ) {
        masterController.journeyVisibilityController.highlight(jd)
        masterController.api.uiEvents.postEvent("VisibilityChanged", data: MasterEventData())
        
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(5),
            target: self,
            selector: "unhighlight",
            userInfo: nil,
            repeats: false)
    }
    
    func unhighlight() {
        masterController.journeyVisibilityController.unhighlightAll()
        masterController.api.uiEvents.postEvent("VisibilityChanged", data: MasterEventData())
        //tableView.reloadData()
    }
    
    func longhit( jd : JourneyDisplay ) {
        let vstate = masterController.journeyVisibilityController.getCurrentState()
        switch vstate.state {
        case vstate.S_ALL:
            highlight(jd)
            break
        case vstate.S_ROUTE:
            highlight(jd)
            if jd.route.isJourney() {
                centerMap(jd)
            }
            break
        case vstate.S_ROUTE:
            highlight(jd)
            if jd.route.isRouteDefinition() {
                centerMap(jd)
            }
            break
        default:
            if (BLog.ERROR) { BLog.logger.error("Bad Vstate \(vstate.state)") }
        }
    }
    
    func hit(jd : JourneyDisplay) {
        let vstate = masterController.journeyVisibilityController.getCurrentState()
        switch vstate.state {
        case vstate.S_ALL:
            if jd.route.isRouteDefinition() {
                masterController.journeyVisibilityController.onRouteCodeSelected(jd.route.code!)
                masterController.api.uiEvents.postEvent("VisibilityChanged", data: MasterEventData())
            }
            break
        case vstate.S_ROUTE:
            if jd.route.isJourney() {
                masterController.journeyVisibilityController.onVehicleSelected(jd)
                masterController.api.uiEvents.postEvent("VisibilityChanged", data: MasterEventData())
            }
            break
        case vstate.S_VEHICLE:
            if jd.route.isRouteDefinition() {
                masterController.journeyVisibilityController.goBack()
                masterController.api.uiEvents.postEvent("VisibilityChanged", data: MasterEventData())
            } else {
                centerMap(jd)
            }
            break
        default:
            if (BLog.ERROR) { BLog.logger.error("Bad Vstate \(vstate.state)") }
        }
        // TODO: This will happen with the visibilitiy changed event.
        //tableView.reloadData()
    }
    
    func resizeIt(notification: NSNotification) {
        let object = notification.object!
        let orient = UIDevice.currentDevice().orientation
        if orient == UIDeviceOrientation.FaceUp || orient == UIDeviceOrientation.FaceDown {
            
        } else {
            self.orientation = UIDeviceOrientationIsLandscape(orient) ? UIDeviceOrientation.LandscapeLeft : UIDeviceOrientation.Portrait
        }
        resizeAll()
        
    }
    
    func onSwipeRight() {
        slideOut()
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
            view.frame.origin = CGPoint(x: origin.x + size.width + 10, y: origin.y)
        })
        tabButton.slideIn()
        self.viewIsOut = true
    }
    
    func slideIn() {
        UIView.animateWithDuration(1.0, animations: {
            self.view.alpha = 1.0
            self.view.frame.origin = self.viewOrigin
        })
        tabButton.slideOut()
        self.viewIsOut = false
    }
    
    func toggleSlide() {
        if viewIsOut {
            slideIn()
        } else {
            slideOut()
        }
    }
    
    private var superFrames : [UIDeviceOrientation:CGRect] = [UIDeviceOrientation:CGRect]()
    private var originalDeviceOrientation : UIDeviceOrientation?
    private var orientation : UIDeviceOrientation?
    override func viewWillAppear(animated: Bool) {
        if view.superview == nil {
            return
        }
        if originalDeviceOrientation == nil {
            originalDeviceOrientation = UIDevice.currentDevice().orientation
            let origin = view.superview!.frame.origin
            let size = view.superview!.frame.size
            if UIDeviceOrientationIsLandscape(originalDeviceOrientation!) {
                orientation = UIDeviceOrientation.LandscapeLeft
                superFrames[UIDeviceOrientation.LandscapeLeft] = CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
                superFrames[UIDeviceOrientation.Portrait] = CGRect(x: origin.y, y: origin.x, width: size.height, height: size.width)
            } else {
                orientation = UIDeviceOrientation.Portrait
                superFrames[UIDeviceOrientation.Portrait] = CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
                superFrames[UIDeviceOrientation.LandscapeLeft] = CGRect(x: origin.y, y: origin.x, width: size.height, height: size.width)
            }
        }
        tableView.rowHeight = 48.0
        resizeAll()
    }
    
    func resizeAll() {
        if orientation != nil {
            let b = superFrames[orientation!]!
            var screenRect = CGRect(x: b.origin.x, y: b.origin.y, width: b.size.width, height: b.size.height)
            
            let navBarEnd = UIDeviceOrientationIsLandscape(orientation!) ? CGFloat(60.0) : CGFloat(70.0)
            
            let screenX = screenRect.origin.x
            let screenWidth = screenRect.size.width
            
            let viewSize = CGSize(width: min(screenWidth * 0.8, 250), height: screenRect.size.height/4.0)
            
            let outsideOrigin = CGPoint(x: screenX + screenWidth + 10, y: navBarEnd)
            let insideOrigin = CGPoint(x: screenX + screenWidth - viewSize.width, y: navBarEnd)
            let tbOutsideOrigin = CGPoint(x: screenX + screenWidth + 10, y: navBarEnd)
            let tbInsideOrigin = CGPoint(x: screenX + screenWidth - tabButton.frame.size.width, y: navBarEnd)
            
            // relative to the view.
            backButton.frame.origin = CGPoint(x: viewSize.width - backButton.frame.size.width, y: 0)
            
            viewOrigin = insideOrigin
            tabButton.viewOrigin = tbInsideOrigin
            
            if viewIsOut {
                view.frame = CGRect(origin: outsideOrigin, size: viewSize)
                tabButton.frame.origin = tbInsideOrigin
            } else {
                view.frame = CGRect(origin: insideOrigin, size: viewSize)
                tabButton.frame.origin = tbOutsideOrigin
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journeyDisplays.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("RouteCell") as RouteCell?
        if cell == nil {
            cell = RouteCell(style: UITableViewCellStyle.Default)
            cell!.autoresizingMask = UIViewAutoresizing.FlexibleWidth|UIViewAutoresizing.FlexibleLeftMargin|UIViewAutoresizing.FlexibleRightMargin
            cell!.clipsToBounds = true // fix for changed default in 7.1
        }
        cell!.handleJourneyDisplay(journeyDisplays[indexPath.row])
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 36.5
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as RouteCell
        hit(cell.journeyDisplay!)
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}