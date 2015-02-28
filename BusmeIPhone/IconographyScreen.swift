//
//  IconographyScreen.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 2/28/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

class IconTableCell : UITableViewCell {
    
    init(image: UIImage, title: String, description: String) {
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "IconCell")
        imageView!.contentMode = UIViewContentMode.Center
        imageView!.image = image
        textLabel!.text = title
        detailTextLabel!.numberOfLines = 0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        let attrText = NSAttributedString(string: description, attributes: [NSParagraphStyleAttributeName:paragraphStyle])
        detailTextLabel!.attributedText = attrText
        fixConstraints()
    }
    
    // Better than the defaults, but still sucks. My gawd, this platform sucks.
    func fixConstraints() {
        let views = ["image" : imageView!, "text" : textLabel!, "detail" : detailTextLabel!]
        var constraints  : [AnyObject]  = [AnyObject]()
        
        imageView!.setTranslatesAutoresizingMaskIntoConstraints(false)
        textLabel!.setTranslatesAutoresizingMaskIntoConstraints(false)
        detailTextLabel!.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("H:|-4-[image(45)]|",
            options: NSLayoutFormatOptions.AlignAllCenterY, metrics: [NSObject:AnyObject](), views: views))
        constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("H:|-53-[detail]|",
            options: NSLayoutFormatOptions.AlignAllCenterY, metrics: [NSObject:AnyObject](), views: views))
        constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("V:|[text][detail]|",
            options: NSLayoutFormatOptions.AlignAllLeft, metrics: [NSObject:AnyObject](), views: views))
        constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("V:|[image]|",
            options: NSLayoutFormatOptions.AlignAllLeft, metrics: [NSObject:AnyObject](), views: views))
        contentView.addConstraints(constraints)
    }
    

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class IconographyScreen : UITableViewController {
    
    var icons : [(UIImage, String, String)] = []
    
    func scale(image : UIImage, scale: Double) -> UIImage {
        return UIImage(CGImage: image.CGImage, scale: CGFloat(scale), orientation: UIImageOrientation.Down)!
    }
    
    func scaleFlip(image : UIImage, scale: Double) -> UIImage {
        // Is this scale a fucking denominator???
        return UIImage(CGImage: image.CGImage, scale: CGFloat(scale), orientation: UIImageOrientation.Up)!
    }
    
    func initIt() -> IconographyScreen {
        self.title = "Iconography"
        
        icons.insert((JourneyIcon.getIconImage(JourneyIcon.ROUTE_ICON)!,
            "Route",
            "Route that does not have active vehicles."),
            atIndex: 0)
        icons.insert((JourneyIcon.getIconImage(JourneyIcon.ROUTE_ICON_ACTIVE)!,
            "Active Route",
            "Route that has active active vehicles."),
            atIndex: 1)
        icons.insert((scaleFlip(Locators.getArrow("blue", reported: false)!.getDirection(0).image, scale: 4),
            "Vehicle Location",
            "Estimated location of vehicle on a specific journey."),
            atIndex: 2)
        icons.insert((scaleFlip(Locators.getArrow("blue", reported: true)!.getDirection(0).image, scale: 4),
            "Reported Vehicle Location",
            "Recently reported location of vehicle on a specific journey."),
            atIndex: 3)
        icons.insert((scaleFlip(Locators.getStarting("purple")!.getDirection(0).image, scale: 4),
            "Starting Location",
            "Vehicle starting location and is about to leave. The darker the transparency means the closer to the start time between 0 and 10 minutes."),
            atIndex: 4)
        icons.insert((scaleFlip(Locators.getTooEarly("blue")!.getIcon().image, scale: 1),
            "Starting Location Marker",
            "Vehicle starting location for a Journey: Used to mark it, but it may be before 10 minutes."),
            atIndex: 5)
        icons.insert((scaleFlip(Locators.getReporting("passenger")!.getIcon().image, scale: 2),
            "Reporting Location",
            "You are reporting this location as a passenger."),
            atIndex: 6)
        icons.insert((scaleFlip(Locators.getReporting("driver")!.getIcon().image, scale: 2),
            "Reporting Driver Location",
            "You are reporting this location as a driver."),
            atIndex: 7)
        return self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationItem.title = title
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return icons.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let index = indexPath.row
        let (i,t,d) = icons[index]
        let icon = IconTableCell(image: i, title: t, description: d)
        return icon
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let index = indexPath.row
        return getHeight(index)

    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let index = indexPath.row
        return getHeight(index)
    }
    
    func getHeight(row : Int) -> CGFloat {
        let (i,t,d) = icons[row]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        let attrText = NSAttributedString(string: d, attributes: [NSParagraphStyleAttributeName:paragraphStyle])
        let boundsWidth = UIScreen.mainScreen().bounds.width - 60
        let options = unsafeBitCast(NSStringDrawingOptions.UsesLineFragmentOrigin.rawValue |
            NSStringDrawingOptions.UsesFontLeading.rawValue,
            NSStringDrawingOptions.self)
        let rect = attrText.boundingRectWithSize(CGSize(width: boundsWidth, height: 2000), options: options, context: nil)
        return rect.height + 35
    }
}