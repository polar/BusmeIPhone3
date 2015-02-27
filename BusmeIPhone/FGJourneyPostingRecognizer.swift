//
//  FGJourneyPostingRecognizer.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 2/26/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class JourneyPostingRecognizerEventData {
    var journeyDisplays : [JourneyDisplay] = []
    init(journeyDisplays: [JourneyDisplay]) {
        self.journeyDisplays = journeyDisplays
    }
    init() {
        
    }
}

class FGJourneyPostingRecognizer : NSObject, BuspassEventListener, UIAlertViewDelegate {
    
    weak var api : BuspassApi!
    weak var masterMapScreen : MasterMapScreen!
    weak var masterController : MasterController!
    
    var journeyDisplays : [JourneyDisplay]?
    var alertView : UIAlertView?
    var dismissedAt : TimeValue64?
    var journeyPostingRequestInProgress = false
    
    init(masterMapScreen : MasterMapScreen) {
        self.masterMapScreen = masterMapScreen
        self.masterController = masterMapScreen.masterController
        self.api = masterMapScreen.api
        super.init()
        registerForEvents()
        
    }
    
    func registerForEvents() {
        api.uiEvents.registerForEvent("JourneyPostingRequest", listener: self)
        api.uiEvents.registerForEvent("JourneyPostingRequestClear", listener: self)
    }
    
    func unregisterForEvents() {
        api.uiEvents.unregisterForEvent("JourneyPostingRequest", listener: self)
        api.uiEvents.unregisterForEvent("JourneyPostingRequestClear", listener: self)
    }

    func onBuspassEvent(event: BuspassEvent) {
        if event.eventName == "JourneyPostingRequest" {
            onJourneyPostingRequest(event.eventData as JourneyPostingRecognizerEventData)
        } else if event.eventName == "JourneyPostingRequestClear" {
            journeyPostingRequestInProgress = false
        }
    }
    
    func onJourneyPostingRequest(eventData: JourneyPostingRecognizerEventData) {
        
        if !journeyPostingRequestInProgress {
            if dismissedAt != nil {
                let diff = UtilsTime.current() - dismissedAt!
                if diff < 10 * 60 * 1000 { // 10 minutes
                    return
                }
            }
            journeyPostingRequestInProgress = true
            self.journeyDisplays = eventData.journeyDisplays
            if masterController.api.isLoggedIn() {
                if !masterController.journeyLocationPoster.isPosting() {
                    if journeyDisplays!.count == 1 {
                        let route = journeyDisplays![0].route
                        let startT = route.getStartTime()
                        let endT = route.getEndTime()
                        let msg = "Are you on the bus \(route.code!) - \(route.name!) \(UtilsTime.hhmmaForTime(startT)) - \(UtilsTime.hhmmaForTime(endT)))"
                        alertView = UIAlertView(title: "On The Bus?", message: msg, delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
                    } else {
                        var codes = [String:String]()
                        for jd in journeyDisplays! {
                            codes[jd.route.code!] = jd.route.code!
                        }
                        let msg = "There are \(journeyDisplays!.count) buses for routes \(codes). Are you on one of these buses?"
                        alertView = UIAlertView(title: "On The Bus?", message: msg, delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
                    }
                    alertView!.show()
                }
            }
        }
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if journeyDisplays != nil {
            if buttonIndex == 1 {
                if journeyDisplays!.count == 1 {
                    let route = journeyDisplays![0].route
                    let evd = JourneyEventData(route: route, role: "passenger", reason: 0)
                    api.bgEvents.postEvent("JourneyStartPosting", data: evd)
                } else {
                    masterMapScreen.showSelections(journeyDisplays!, role: "passenger")
                }
                dismissedAt = nil
            } else {
                dismissedAt = UtilsTime.current()
            }
        }
    }
}