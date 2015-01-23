//
//  MasterMessageViewController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/21/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

class MasterMessageViewController : UIViewController, UIAlertViewDelegate {
    let B_GO = 1
    let B_REMIND = 2
    let B_OK = 3
    let B_CANCEL = 0
    
    weak var masterMapScreen : MasterMapScreen!
    var api : BuspassApi?
    var masterMessage : MasterMessage!
    var buttonIndexes : [Int] = [Int]()
    var alertView : UIAlertView?
    
    init(masterMapScreen : MasterMapScreen, masterMessage : MasterMessage) {
        // Why does this need to go here? Ugg
        super.init(nibName: nil, bundle: nil)
        self.masterMessage = masterMessage
        self.masterMapScreen = masterMapScreen
        self.api = masterMapScreen.masterController.api
        
        self.alertView = UIAlertView(title: masterMessage.title, message: masterMessage.content, delegate: nil, cancelButtonTitle: "Cancel")
        
        buttonIndexes.insert(B_CANCEL, atIndex: 0)
        var index = 1
        if masterMessage.goUrl != nil {
            var goLabel = "Go"
            if masterMessage.goLabel != nil {
                goLabel = masterMessage.goLabel!
            }
            alertView!.addButtonWithTitle(goLabel)
            buttonIndexes.insert(B_GO, atIndex: index)
            index += 1
        }
        if masterMessage.remindable {
            alertView!.addButtonWithTitle("Remind")
            buttonIndexes.insert(B_REMIND, atIndex: index)
            index += 1
        }
        
        if true {
            alertView!.addButtonWithTitle("OK")
            buttonIndexes.insert(B_OK, atIndex: index)
            index += 1
        }
        // WTF? Is going on?
        //super.init(nibName: nil, bundle: nil)
        alertView!.delegate = self
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        var eventData = MasterMessageEventData(masterMessage: masterMessage)
        eventData.state = MasterMessageEvent.S_RESOLVE
        eventData.time = UtilsTime.current()

        switch(buttonIndexes[buttonIndex]) {
        case B_CANCEL:
            if BLog.DEBUG { BLog.logger.debug("B_CANCEL \(buttonIndex)") }
            eventData.resolve = MasterMessageEvent.R_CANCEL
            api?.uiEvents.postEvent("MasterMessageEvent", data: eventData);
            break
        case B_REMIND:
            if BLog.DEBUG { BLog.logger.debug("B_REMIND \(buttonIndex)") }
            eventData.resolve = MasterMessageEvent.R_REMIND
            api?.uiEvents.postEvent("MasterMessageEvent", data: eventData);
        case B_OK:
            if BLog.DEBUG { BLog.logger.debug("B_OK \(buttonIndex)") }
            eventData.resolve = MasterMessageEvent.R_REMOVE
            api?.uiEvents.postEvent("MasterMessageEvent", data: eventData);
        case B_GO:
            if BLog.DEBUG { BLog.logger.debug("B_GO \(buttonIndex)") }
            eventData.resolve = MasterMessageEvent.R_GO
            api?.uiEvents.postEvent("MasterMessageEvent", data: eventData);
            break
        default:
            if BLog.DEBUG { BLog.logger.debug("default \(buttonIndex)") }
            break
        }
    }
    
    func display() {
        alertView?.show()
    }
    
    func displayWebPage(url : String?) {
        var theURL = url
        if theURL == nil {
            theURL = masterMessage.goUrl
        }
        if theURL != nil {
            let webScreen = WebScreen()
            webScreen.openUrl(theURL!)
            masterMapScreen.navigationController?.pushViewController(webScreen, animated: true)
        }
    }
    
    func dismiss() {
        if BLog.DEBUG { BLog.logger.debug("Forced Dismiss \(masterMessage.title)") }
        alertView?.dismissWithClickedButtonIndex(0, animated: true)
    }
    
}