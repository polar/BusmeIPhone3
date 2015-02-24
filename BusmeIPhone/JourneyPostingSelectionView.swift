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
        let startTime = UtilsTime.hhmmaForTime(journeyDisplay.route.getStartTime())
        let endTime = UtilsTime.hhmmaForTime(journeyDisplay.route.getEndTime())
        let route = "\(journeyDisplay.route.code!) \(startTime) - \(endTime)"
        let vid = journeyDisplay.route.vid == nil ? "" : "Vid \(journeyDisplay.route.vid): "

        let ans = journeyDisplay.currentDistanceFromRoute()
        if ans != nil {
            let (point, dist) = ans!
            if dist > 100.0 {
                UIAlertView(title: "Report on Route \(route)", message: "\(vid)You are \(dist) feet from the route. Do you still want to report?", delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Yes").show()
            } else {
                Toast(title: "Reporting on Route \(route)", message: "You are now reporting on Route \(route) \(vid)", duration: 5).show()
                
                api.bgEvents.postEvent("JourneyStartPosting", data: JourneyEventData(route: currentJourneyDisplay!.route, role: role, reason: JourneyEvent.R_NORMAL))
                navigationController?.popToRootViewControllerAnimated(true)
                currentJourneyDisplay = nil
            }
        } else {
            Toast(title: "Report on Route \(route)", message: "Reporting on Route \(route) \(vid) is not available", duration: 10).show()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if alertView.buttonTitleAtIndex(buttonIndex) == "Yes" {
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