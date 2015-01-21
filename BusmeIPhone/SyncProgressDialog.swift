//
//  SyncProgressDialog.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/20/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit


class SyncProgressDialogController : NSObject, UIAlertViewDelegate, BuspassEventListener {
    var dialog : UIAlertView
    var api : BuspassApi
    
    init(api: BuspassApi, master : Master) {
        self.api = api
        self.dialog = UIAlertView(title: master.name, message: "Welcome", delegate: nil, cancelButtonTitle: "Dismiss")
        super.init()
        dialog.delegate = self
        registerForEvents()
    }
    
    func registerForEvents() {
        api.uiEvents.registerForEvent("JourneySyncProgress", listener: self)
    }
    func unregisterForEvents() {
        api.uiEvents.unregisterForEvent("JourneySyncProgress", listener: self)
    }
    
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventData = event.eventData as? JourneySyncProgressEventData
        if eventData != nil {
            switch(eventData!.action) {
            case JourneySyncProgressEvent.P_BEGIN:
                if eventData!.isForced {
                    dialog.show()
                }
                break
            case JourneySyncProgressEvent.P_SYNC_END:
                dialog.message = "Getting \(eventData!.nRoutes) routes."
                break
            case JourneySyncProgressEvent.P_ROUTE_END:
                dialog.message = "Got \(eventData!.iRoute + 1) of \(eventData!.nRoutes) routes."
                break
            case JourneySyncProgressEvent.P_DONE:
                dialog.dismissWithClickedButtonIndex(0, animated: true)
            default:
                break
            }
        }
    }
    
    
    
}