//
//  UIMarker.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/20/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreGraphics

class UIMarker : UIButton {
    var markerInfo : MarkerInfo
    
    init(markerInfo : MarkerInfo) {
        self.markerInfo = markerInfo
        super.init(frame: CGRect())
        self.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        //self.titleLabel!.layer.shadowOffset = Size(1,1)
        self.setTitleShadowColor(UIColor.grayColor(), forState: UIControlState.Normal)
        self.setTitle(markerInfo.title!, forState: UIControlState.Normal)
        prepareBackgroundImage(markerInfo.title!)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //          (---------)
    //         =|         |
    //        / (---------)
    //       /
    //      /
    //     -----|----------|
    //   pointer  balloon
    func prepareBackgroundImage(text : String) {
        // Margins within the text Rect
        let x_margin = CGFloat(5.0)
        let y_margin = CGFloat(1.0)
        
        let dynamicFont = self.titleLabel?.font
        let constrainSize = CGSize(width: 200, height: 37)
        let attributes : [NSObject: AnyObject!] = [NSFontAttributeName : dynamicFont]
        let opts = NSStringDrawingOptions.UsesLineFragmentOrigin
        let rect = (text as NSString).boundingRectWithSize(constrainSize, options: opts, attributes: attributes, context: nil)
        
        // These images are the same height
        let pointer = UIImage(named: "marker_pointer_unviewed.png")
        let balloon = UIImage(named: "map_marker_unviewed.png")
        
        // We are going to put the text in the balloon, which is at this rect. The
        // balloon should have x_margin space on each horizontal size, and y_margin
        // on each vertical side.
        let x : CGFloat = CGFloat(pointer!.size.width)
        let y : CGFloat = CGFloat(pointer!.size.height - rect.size.height + y_margin * 2.0)
        let width : CGFloat = CGFloat(rect.size.width + x_margin * 2.0)
        let height : CGFloat = CGFloat(pointer!.size.height - rect.size.height + y_margin * 2.0)
        let textRect = CGRect(x: x, y: y, width: width, height: height)
        // The size of the entire image should be the pointer + the width of the text rect
        // and the height of the images, which are the same height
        let img_size = CGSize(width: pointer!.size.width + textRect.size.width, height: pointer!.size.height)
        
        UIGraphicsBeginImageContextWithOptions(img_size, false, 1)
        let imgCtx = UIGraphicsGetCurrentContext()
        pointer!.drawAtPoint(CGPoint())
        let insets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 45)
        let img = balloon!.resizableImageWithCapInsets(insets)
        img.drawInRect(CGRect(x: x, y: 0.0, width: textRect.size.width, height: pointer!.size.height))
        let pointed = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(pointed, forState: UIControlState.Normal)
        let centerRect = CGRect(origin: CGPoint(), size: pointed.size)
        let titleCenter = CGPoint(x: CGRectGetMidX(centerRect), y: CGRectGetMidY(centerRect))
        let textRectCenter = CGPoint(x: CGRectGetMidX(textRect), y: CGRectGetMidY(textRect))
        let top = textRectCenter.y - titleCenter.y + y_margin
        let left = textRectCenter.x - titleCenter.x + x_margin
        let w = UIEdgeInsets(top: -top, left: left, bottom: 0, right: 0)
        self.titleEdgeInsets = w
        self.frame.size = pointed.size
    }
    
}