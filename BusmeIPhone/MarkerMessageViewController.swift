//
//  MarkerMessageViewController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/21/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

class MarkerMessageViewController : UIViewController, UIAlertViewDelegate {
    let B_GO = 1
    let B_REMOVE = 2
    let B_CANCEL = 0
    
    weak var masterMapScreen : MasterMapScreen!
    var api : BuspassApi!
    var markerInfo : MarkerInfo!
    var buttonIndexes : [Int] = [Int]()
    var alertView : UIAlertView?
    
    init(masterMapScreen : MasterMapScreen, markerInfo : MarkerInfo) {
        // Why does this need to go here? Ugg
        super.init(nibName: nil, bundle: nil)
        self.markerInfo = markerInfo
        self.masterMapScreen = masterMapScreen
        self.api = masterMapScreen.masterController.api
        
        self.alertView = UIAlertView(title: markerInfo.title, message: markerInfo.content, delegate: nil, cancelButtonTitle: "Cancel")
        
        buttonIndexes.insert(B_CANCEL, atIndex: 0)
        var index = 1
        if markerInfo.goUrl != nil {
            var goLabel = "Go"
            if markerInfo.goLabel != nil {
                goLabel = markerInfo.goLabel!
            }
            alertView!.addButtonWithTitle(goLabel)
            buttonIndexes.insert(B_GO, atIndex: index)
            index += 1
        }
        if true {
            alertView!.addButtonWithTitle("Remove")
            buttonIndexes.insert(B_REMOVE, atIndex: index)
            index += 1
        }
        // WTF? Is going on?
        //super.init(nibName: nil, bundle: nil)
        alertView!.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeFromController() {
        masterMapScreen.fgMarkerPresentationController.removeCurrent(self)
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        var eventData = MarkerEventData(markerInfo: markerInfo)
        eventData.state = MarkerEvent.S_RESOLVE
        eventData.time = UtilsTime.current()

        switch(buttonIndexes[buttonIndex]) {
        case B_CANCEL:
            if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("B_CANCEL \(buttonIndex)") }
            eventData.resolve = MarkerEvent.R_CANCEL
            api?.uiEvents.postEvent("MarkerEvent", data: eventData);
            removeFromController()
            break
            
        case B_REMOVE:
            if BLog.DEBUG { BLog.logger.debug("B_REMOVE \(buttonIndex)") }
            eventData.resolve = MarkerEvent.R_CANCEL
            api?.uiEvents.postEvent("MarkerEvent", data: eventData);
            removeFromController()
            break

        case B_GO:
            if BLog.DEBUG { BLog.logger.debug("B_GO \(buttonIndex)") }
            eventData.resolve = MarkerEvent.R_GO
            api?.uiEvents.postEvent("MarkerEvent", data: eventData);
            break
            
        default:
            if BLog.DEBUG { BLog.logger.debug("default \(buttonIndex)") }
            removeFromController()

            break
        }
    }
    
    func display() {
        alertView?.show()
    }
    
    func displayWebPage(url : String?) {
        var theURL = url
        if theURL == nil {
            theURL = markerInfo.goUrl
        }
        if theURL != nil {
            let webScreen = WebScreen()
            webScreen.openUrl(theURL!)
            masterMapScreen.navigationController?.pushViewController(webScreen, animated: true)
        }
        removeFromController()
    }
    
    func dismiss() {
        if BLog.DEBUG { BLog.logger.debug("Forced Dismiss \(markerInfo.title)") }
        alertView?.dismissWithClickedButtonIndex(0, animated: true)
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
    
}