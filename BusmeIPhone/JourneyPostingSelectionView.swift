//
//  JourneyPostingSelectionView.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 2/17/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

class JourneyPostingSelectionView : UITableViewController, UIAlertViewDelegate {
    var api : BuspassApi
    var journeyDisplays : [JourneyDisplay]
    var role : String
    init(api: BuspassApi, role: String, journeyDisplays: [JourneyDisplay]) {
        self.api = api
        self.role = role
        self.journeyDisplays = journeyDisplays
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Select Reporting"
    }
    
    var needJourneyPostingRequestClear = true
    override func viewDidDisappear(animated: Bool) {
        if needJourneyPostingRequestClear {
            api.uiEvents.postEvent("JourneyPostingRequestClear", data: JourneyPostingRecognizerEventData())
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return journeyDisplays.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("JourneyCell") as? JourneyCell
        if cell == nil {
            cell = JourneyCell(style: UITableViewCellStyle.Default)
            cell!.autoresizingMask = UIViewAutoresizing.FlexibleWidth|UIViewAutoresizing.FlexibleLeftMargin|UIViewAutoresizing.FlexibleRightMargin
            cell!.clipsToBounds = true // fix for changed default in 7.1
        }
        cell!.handleJourneyDisplay(journeyDisplays[indexPath.row])
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 36.5
    }
    
    var currentJourneyDisplay : JourneyDisplay?
    func confirm(journeyDisplay: JourneyDisplay) {
        currentJourneyDisplay = journeyDisplay
        let route = journeyDisplay.route
        let startTime = UtilsTime.hhmmaForTime(route.getStartTime())
        let endTime = UtilsTime.hhmmaForTime(route.getEndTime())
        let routeName = "\n\(route.code!) :\(route.name!)\n\(startTime) - \(endTime)"
        let vid = journeyDisplay.route.vid == nil ? "" : "\nVid \(journeyDisplay.route.vid)\n"

        let ans = journeyDisplay.currentDistanceFromRoute()
        if ans != nil {
            let (point, dist) = ans!
            if dist > 100.0 {
                UIAlertView(title: "Report on Route \(routeName)", message: "\(vid)You are \(dist) feet from the route. Do you still want to report?", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Yes").show()
            } else {
                Toast(title: "Reporting on Route \(routeName)", message: "You are now reporting on Route \(routeName) \(vid)", duration: 5).show()
                // The RequestClear will come from JourneyLocationPoster after it starts posting
                needJourneyPostingRequestClear = false
                api.bgEvents.postEvent("JourneyStartPosting", data: JourneyEventData(route: route, role: role, reason: JourneyEvent.R_NORMAL))
                navigationController?.popToRootViewControllerAnimated(true)
                currentJourneyDisplay = nil
            }
        } else {
            Toast(title: "Report on Route \(routeName)", message: "Reporting on Route \(routeName) \(vid). You have no good GPS location for your device.", duration: 10).show()
            navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.buttonTitleAtIndex(buttonIndex) == "Yes" {
            // The RequestClear will come from JourneyLocationPoster after it starts posting
            needJourneyPostingRequestClear = false
            api.bgEvents.postEvent("JourneyStartPosting", data: JourneyEventData(route: currentJourneyDisplay!.route, role: role, reason: JourneyEvent.R_NORMAL))
        }
        navigationController?.popToRootViewControllerAnimated(true)
        currentJourneyDisplay = nil
    }
    
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        navigationController?.popToRootViewControllerAnimated(true)
        currentJourneyDisplay = nil
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let jd = journeyDisplays[indexPath.row]
        confirm(jd)
    }
}