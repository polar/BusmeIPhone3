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
    var markerInfo : MarkerInfo
    var buttonIndexes : [Int] = [Int]()
    let alertView : UIAlertView
    
    init(masterMapScreen : MasterMapScreen, markerInfo : MarkerInfo) {
        self.markerInfo = markerInfo
        self.masterMapScreen = masterMapScreen
        
        let content = markerInfo.content == nil ? "" : markerInfo.content!
        
        self.alertView = UIAlertView(title: markerInfo.title!, message: content, delegate: nil, cancelButtonTitle: "Cancel", otherButtonTitles:  "")
        
        buttonIndexes.insert(B_CANCEL, atIndex: 0)
        var index = 1
        if markerInfo.goUrl != nil {
            alertView.addButtonWithTitle("Go")
            buttonIndexes.insert(B_GO, atIndex: index)
            index += 1
        }
        if true {
            alertView.addButtonWithTitle("REMOVE")
            buttonIndexes.insert(B_REMOVE, atIndex: index)
            index += 1
        }
        super.init(nibName: nil, bundle: nil)
        alertView.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        switch(buttonIndexes[buttonIndex]) {
        case B_CANCEL:
            if BLog.DEBUG { BLog.logger.debug("B_CANCEL \(buttonIndex)") }
            break
        case B_REMOVE:
            if BLog.DEBUG { BLog.logger.debug("B_REMOVE \(buttonIndex)") }
            masterMapScreen.masterController!.markerPresentationController.removeMarker(markerInfo)
        case B_GO:
            if BLog.DEBUG { BLog.logger.debug("B_GO \(buttonIndex)") }
            let webScreen = WebScreen()
            webScreen.openUrl(markerInfo.goUrl!)
            masterMapScreen.navigationController?.pushViewController(webScreen, animated: true)
            break
        default:
            if BLog.DEBUG { BLog.logger.debug("default \(buttonIndex)") }
            break
        }
    }
    
    func display() {
        alertView.show()
    }
    
    func dismiss() {
        alertView.dismissWithClickedButtonIndex(0, animated: true)
    }
    
}