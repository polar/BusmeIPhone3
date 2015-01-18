//
//  RouteCell.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/18/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

class RouteCell : UITableViewCell {
    
    let ICONS = ["route_icon.png",
        "route_icon_active.png",
        "purple_dot_icon.png",
        "blue_circle_icon.png",
        "green_arrow_icon.png",
        "blue_arrow_icon.png",
        "bus_icon_active.png",
        "red_arrow_icon.png"]

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var timeFormat : String!
    
    var iconView : UIImageView!
    var nameView : UIView!
    var routeNameLabel : UILabel
    var dirLabel : UILabel!
    var nameCenterView : UIView!
    var routeCodeLabel : UILabel

    var vidLabel : UILabel!
    var vidLabelView : UILabel!
    var timesLabel : UILabel!
    
    var labelFontSize : CGFloat
    var labelFont : UIFont
    var contentConstraints : [AnyObject]
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.timeFormat = "%H:%S %P"
        self.labelFontSize = UIFont.labelFontSize() - 4
        self.labelFont = UIFont.systemFontOfSize(labelFontSize)
        
        // We get rid of the initial subviews from the TableViewCell because we don't like their constraints
        self.iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        // Route/Dir
        
        self.nameView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.routeNameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.dirLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        // So we can center name/dir vertically
        self.nameCenterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.routeCodeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.vidLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.vidLabelView = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.timesLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        self.contentConstraints = [AnyObject]()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.bounds = CGRect(x: 0, y: 0, width: 999999, height: 999999)
        imageView?.removeFromSuperview()
        textLabel?.removeFromSuperview()
        detailTextLabel?.removeFromSuperview()
        nameView.addSubview(routeNameLabel)
        nameView.addSubview(dirLabel)


        dirLabel.textAlignment = NSTextAlignment.Right
        routeCodeLabel.textAlignment = NSTextAlignment.Right
        
        nameCenterView.addSubview(nameView)
        
        contentView.addSubview(iconView)
        contentView.addSubview(routeCodeLabel)
        contentView.addSubview(vidLabelView)
        contentView.addSubview(nameCenterView)
        contentView.addSubview(timesLabel)
        
        prepareVid()
        prepareNameDir()
        prepareNameCenter()
        
        timesLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        iconView.setTranslatesAutoresizingMaskIntoConstraints(false)
        routeCodeLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        vidLabelView.setTranslatesAutoresizingMaskIntoConstraints(false)
        nameCenterView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
    }
    
    func willDisplay(journeyDisplay : JourneyDisplay) {
        iconView.image = UIImage(named: ICONS[journeyDisplay.getIcon()-1])
        if journeyDisplay.route.isJourney() {
            prepareJourney(journeyDisplay)
        } else {
            prepareRouteDefinition(journeyDisplay)
        }
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
    }
    
    func prepareVid() {
        let views : [NSObject:AnyObject] = ["vid" : vidLabel]
        var constraints  : [AnyObject]  = [AnyObject]()
        
        constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("V:|[vid]|",
            options: NSLayoutFormatOptions.AlignAllLeft, metrics: [NSObject:AnyObject](), views: views))
        constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("H:|[vid]|",
            options: NSLayoutFormatOptions.allZeros, metrics: [NSObject:AnyObject](), views: views))
        
        vidLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        vidLabelView.addConstraints(constraints)
    }
    
    
    func prepareNameDir() {
        let views : [NSObject:AnyObject] = ["title" : routeNameLabel, "dir" : dirLabel]
        var constraints  : [AnyObject]  = [AnyObject]()
        
        constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("V:|[title][dir]|",
            options: NSLayoutFormatOptions.AlignAllLeft, metrics: [NSObject:AnyObject](), views: views))
        constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("H:|[title]|",
            options: NSLayoutFormatOptions.allZeros, metrics: [NSObject:AnyObject](), views: views))
        
        routeNameLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        dirLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        nameView.addConstraints(constraints)
    }
    
    func prepareNameCenter() {
        let views : [NSObject:AnyObject] = ["name" : nameView, "superview" : nameCenterView]
        var constraints  : [AnyObject]  = [AnyObject]()
        
        constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("H:[superview]-(<=1)-[name]",
            options: NSLayoutFormatOptions.AlignAllCenterY, metrics: [NSObject:AnyObject](), views: views))
        constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("H:|[name]|",
            options: NSLayoutFormatOptions.allZeros, metrics: [NSObject:AnyObject](), views: views))
        
        nameView.setTranslatesAutoresizingMaskIntoConstraints(false)
        nameCenterView.addConstraints(constraints)
    }


    func prepareJourney(journeyDisplay : JourneyDisplay) {
        let route = journeyDisplay.route
        
        var fullSize : [NSObject:AnyObject] = [ NSFontAttributeName : labelFont.fontWithSize(labelFontSize)]
        if journeyDisplay.isNameHighlighted() {
            fullSize[NSForegroundColorAttributeName] = UIColor.redColor().CGColor
        }
        var smallSize : [NSObject:AnyObject] = [ NSFontAttributeName : labelFont.fontWithSize(labelFontSize - 4)]
        if journeyDisplay.isNameHighlighted() {
            smallSize[NSForegroundColorAttributeName] = UIColor.redColor().CGColor
        }
        var tinySize : [NSObject:AnyObject] = [ NSFontAttributeName : labelFont.fontWithSize(labelFontSize - 6)]
        if journeyDisplay.isNameHighlighted() {
            tinySize[NSForegroundColorAttributeName] = UIColor.redColor().CGColor
        }
        
        let routeCode : NSAttributedString = NSAttributedString(string: route.code!, attributes: fullSize)
        routeCodeLabel.attributedText = routeCode
        let routeCodeLabelSize = routeCode.boundingRectWithSize(CGSize(width: 100,height: 200), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        routeNameLabel.frame.size = routeCodeLabelSize.size

        
        let routeName : NSAttributedString = NSAttributedString(string: route.name!, attributes: fullSize)
        routeNameLabel.attributedText = routeName
        let routeNameLabelSize = routeName.boundingRectWithSize(CGSize(width: 200,height: 200), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        routeNameLabel.frame.size = routeNameLabelSize.size
        
        let vid = route.vid == nil ? "" : route.vid
        let vidText = NSAttributedString(string: route.name!, attributes: fullSize)
        vidLabel.attributedText = vidText
        vidLabel.hidden = false
        
        let dirText = NSAttributedString(string: route.direction!, attributes: fullSize)
        routeNameLabel.attributedText = dirText
        let dirLabelSize = dirText.boundingRectWithSize(CGSize(width: 200,height: 200), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        dirLabel.frame.size = dirLabelSize.size
        dirLabel.hidden = false
        
        
        contentView.removeConstraints(contentConstraints)
        if vidLabelView.superview == nil {
            contentView.addSubview(vidLabelView)
        }
        
        let views = ["times": timesLabel, "image" : iconView, "name" : nameCenterView, "code" : routeCodeLabel, "vid" : vidLabelView]
        var constraints  : [AnyObject]  = [AnyObject]()
        
        constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[image(16)]-8-[code(30)]-4-[vid(<=30)]-4-[name]-[times(40)]|",
            options: NSLayoutFormatOptions.AlignAllCenterY, metrics: [NSObject:AnyObject](), views: views))
        constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("V:|[name]|",
            options: NSLayoutFormatOptions.AlignAllLeft, metrics: [NSObject:AnyObject](), views: views))
        
        self.contentConstraints = constraints
        contentView.addConstraints(constraints)
    
        var times = UtilsTime.stringForTime(route.getStartTime())
        times += "\n"
        times += UtilsTime.stringForTime(route.getEndTime())
        let timesText = NSAttributedString(string: times, attributes: tinySize)
        timesLabel.attributedText = timesText
        timesLabel.frame.size = CGSize(width: 40, height: 60)
        timesLabel.sizeToFit()
        
        nameCenterView.frame.size.height = nameView.frame.size.height + dirLabel.frame.size.height
    }
    
    func prepareRouteDefinition(journeyDisplay : JourneyDisplay) {
        let route = journeyDisplay.route
        
        var fullSize : [NSObject:AnyObject] = [ NSFontAttributeName : labelFont.fontWithSize(labelFontSize)]
        if journeyDisplay.isNameHighlighted() {
            fullSize[NSForegroundColorAttributeName] = UIColor.redColor().CGColor
        }
        
        let routeCode : NSAttributedString = NSAttributedString(string: route.code!, attributes: fullSize)
        routeCodeLabel.attributedText = routeCode
        let routeCodeLabelSize = routeCode.boundingRectWithSize(CGSize(width: 100,height: 200), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        routeNameLabel.frame.size = routeCodeLabelSize.size
        
        let routeName : NSAttributedString = NSAttributedString(string: route.name!, attributes: fullSize)
        routeNameLabel.attributedText = routeName
        let routeNameLabelSize = routeName.boundingRectWithSize(CGSize(width: 200,height: 200), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        routeNameLabel.frame.size = routeNameLabelSize.size
        
        vidLabel.attributedText = nil
        vidLabel.hidden = true
        
        dirLabel.attributedText = nil
        dirLabel.hidden = true
        
        timesLabel.attributedText = nil
        timesLabel.hidden = true
        
        
        contentView.removeConstraints(contentConstraints)
        if vidLabelView.superview == nil {
            contentView.addSubview(vidLabelView)
        }
        
        let views = ["times": timesLabel, "image" : iconView, "name" : nameCenterView, "code" : routeCodeLabel, "vid" : vidLabelView]
        var constraints  : [AnyObject]  = [AnyObject]()
        
        constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("H:|-8-[image(16)]-8-[code(30)]-8-[name]-[times(40)]|",
            options: NSLayoutFormatOptions.AlignAllCenterY, metrics: [NSObject:AnyObject](), views: views))
        constraints.extend(NSLayoutConstraint.constraintsWithVisualFormat("V:|[name]|",
            options: NSLayoutFormatOptions.AlignAllLeft, metrics: [NSObject:AnyObject](), views: views))
        
        self.contentConstraints = constraints
        contentView.addConstraints(constraints)
        nameCenterView.frame.size.height = nameView.frame.size.height + dirLabel.frame.size.height
    }
    
}
