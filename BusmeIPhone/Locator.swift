//
//  Locator.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/26/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

class Icon {
    var image : UIImage
    var hotspot : CGPoint
    init(image : UIImage, hotspot : CGPoint) {
        self.image = image
        self.hotspot = hotspot
    }
    
    func toView(at : CGPoint) {
        let view = UIImageView(image: image)
        view.frame.origin = at
        view.frame.size = image.size
    }
    
    func scaleTo(size : CGSize) -> Icon {
        let matrix = CGAffineTransformMakeScale(size.width, size.height)
        let hp = CGPointApplyAffineTransform(hotspot, matrix)
        return Icon(image: scaleImageTo(image, target_width: size.width, target_height: size.height), hotspot: hp)
    }
    
    func scaleImageTo(image: UIImage, target_width : CGFloat, target_height: CGFloat) -> UIImage {
        return scaleImageTo(image, target_width: Double(target_width), target_height: Double(target_height));
    }
    
    func scaleImageTo(image: UIImage, target_width : Double, target_height: Double) -> UIImage {
        let width = Double(image.size.width)
        let height = Double(image.size.height)
        var scaleFactor = 0.0
        var scaled_width = target_width
        var scaled_height = target_height
        
        var thumbnail_point = CGPoint()
        let width_factor = target_width/width
        let height_factor = target_height/height
        if width_factor < height_factor {
            scaleFactor = width_factor
        } else {
            scaleFactor = height_factor
        }
        scaled_width = width * scaleFactor
        scaled_height = height * scaleFactor
        if width_factor < height_factor {
            thumbnail_point.y = CGFloat((target_height - scaled_height) * 0.5)
        } else if width_factor > height_factor {
            thumbnail_point.x = CGFloat((target_width - scaled_width) * 0.5)
        }
        // scale == 0.0 means default
        UIGraphicsBeginImageContextWithOptions(CGSize(width: target_width, height: target_height), false, 0.0)
        image.drawInRect(CGRect(origin: thumbnail_point, size: CGSize(width: scaled_width, height: scaled_height)))
        let new_image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return new_image
    }
    
    func scaleBy(scale: Double) -> Icon {
        return scaleTo(CGSize(width: image.size.width * CGFloat(scale), height: image.size.height * CGFloat(scale)))
    }
}

struct Locators {
    static var icons = [String:Locator]()
    
    static func getArrow(name : String, reported : Bool ) -> Locator {
        let idxname = "\(name):\(reported):Arrow"
        if Locators.icons[idxname] == nil {
            let image = reported ? UIImage(named: "\(name)_yellow_button.png") : UIImage(named: "\(name)_button.png")
            let arrow = UIImage(named: "\(name)_arrow.png")
            let hotspot = CGPoint(x: 22, y: 30)
            let icon = Locator(baseImage: image!, arrowImage: arrow!, hotspot: hotspot)
            Locators.icons[idxname] = icon
        }
        return Locators.icons[idxname]!
    }
    
    static func getStarting(name: String) -> Locator {
        let idxname = "\(name):Starting"
        if Locators.icons[idxname] == nil {
            let image = UIImage(named: "\(name)_button.png")
            let arrow = UIImage(named: "\(name)_dot.png")
            let hotspot = CGPoint(x: 22, y: 30)
            let icon = Locator(baseImage: image!, arrowImage: arrow!, hotspot: hotspot)
            Locators.icons[idxname] = icon
        }
        return Locators.icons[idxname]!
    }
    
    static func getReporting(name: String) -> Locator {
        let idxname = "\(name):Reporting"
        if Locators.icons[idxname] == nil {
            let image = UIImage(named: "\(name)_icon.png")
            let hotspot = CGPoint(x: 22, y: 30)
            let icon = Locator(baseImage: image!, arrowImage: nil, hotspot: hotspot)
            Locators.icons[idxname] = icon
        }
        return Locators.icons[idxname]!
    }
    
    static func getTooEarly(name: String) -> Locator {
        let idxname = "\(name):TooEarly"
        if Locators.icons[idxname] == nil {
            let image = UIImage(named: "\(name)_circle_icon.png")
            let hotspot = CGPoint(x: 22, y: 30)
            let icon = Locator(baseImage: image!, arrowImage: nil, hotspot: hotspot)
            Locators.icons[idxname] = icon
        }
        return Locators.icons[idxname]!
    }

}

class Locator {
    var baseImage : UIImage
    var arrowImage : UIImage?
    var hotspot : CGPoint
    
    init(baseImage : UIImage, arrowImage : UIImage?, hotspot : CGPoint) {
        self.baseImage = baseImage
        self.arrowImage = arrowImage
        self.hotspot = hotspot
    }
    
    func getDirection(direction: Double) -> Icon {
        if arrowImage != nil {
            let arrow = rotateImageBy(arrowImage!, radians: direction)
            let image = overlay(baseImage, image2: arrow)
            let matrix = CGAffineTransformMakeRotation(CGFloat(direction))
            let hspot = CGPointApplyAffineTransform(hotspot, matrix)
            return Icon(image: image, hotspot: hspot)
        } else {
            return Icon(image: baseImage, hotspot: hotspot)
        }
    }
    
    func getIcon() -> Icon {
        return Icon(image: baseImage, hotspot: hotspot)
    }
    
    func getStartingIcon(measure : Double) -> Icon {
        return Icon(image: opacity(baseImage, alpha: measure), hotspot: hotspot)
    }
    
    func opacity(image: UIImage, alpha: Double) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()
        CGContextScaleCTM(ctx, 1, -1)
        CGContextTranslateCTM(ctx, 0, -image.size.height)
        
        CGContextSetBlendMode(ctx, kCGBlendModeMultiply)
        
        CGContextSetAlpha(ctx, CGFloat(alpha))
        
        let rect = CGRect(origin:CGPoint(), size: image.size)
        
        CGContextDrawImage(ctx, rect, image.CGImage)
        
        let new_image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return new_image
    }
    
    func overlay(image1: UIImage, image2: UIImage) -> UIImage {
        let w = max(image1.size.width, image2.size.width)
        let h = max(image1.size.height, image2.size.height)
        let newSize = CGSize(width: w,height: h)
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        let rect1 = CGRect(origin: CGPoint(x: (w - image1.size.width)/2, y: (h - image1.size.height)/2), size: image1.size)
        let rect2 = CGRect(origin: CGPoint(x: (w - image2.size.width)/2, y: (h - image2.size.height)/2), size: image2.size)
        image1.drawInRect(rect1)
        image2.drawInRect(rect2)
        let new_image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return new_image
    }
    
    func rotateImageBy(image: UIImage, radians : Double) -> UIImage {
        let w = abs(Double(image.size.width) * cos(radians)) + (Double(image.size.height) * sin(radians))
        let h = abs(Double(image.size.height) * cos(radians)) + (Double(image.size.width) * sin(radians))
        let newSize = CGSize(width: w,height: h)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextTranslateCTM(context, newSize.width / 2, newSize.height / 2)
        
        // Rotate the image context
        CGContextRotateCTM(context, CGFloat(radians))
        
        // otherwise it'll be upside down:
        CGContextScaleCTM(context, 1.0, -1.0)
        // Now, draw the rotated/scaled image into the context
        let rect = CGRect(origin: CGPoint(x: -newSize.width/2, y: -newSize.height/2), size: newSize)
        CGContextDrawImage(context, rect, image.CGImage)
        let new_image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return new_image
    }
}