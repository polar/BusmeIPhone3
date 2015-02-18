//
//  JourneyPostingSelectionView.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 2/17/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

class JourneyPostingSelectionView : UITableViewController {
    
    var journeyDisplays : [JourneyDisplay]
    init(journeyDisplays: [JourneyDisplay]) {
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
}