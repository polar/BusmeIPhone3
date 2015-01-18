//
//  TabButton.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/18/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

class TabButton : UIButton {
    weak var routesView : RoutesView?
    
    override init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 64, height: 61))
        setImage(UIImage(named: "tab_left.png"), forState: UIControlState.Normal)
        setImage(UIImage(named: "tab_left_pressed.png"), forState: UIControlState.Selected)
        self.alpha = 0
        self.addTarget(self, action: "onClick", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onClick() {
        routesView!.slideIn()
    }
    
    private var viewOrigin = CGPoint()
    private var viewIsOut : Bool = true
    
    func slideOut() {
        viewOrigin = self.frame.origin
        UIView.animateWithDuration(1.0, animations: {
            let origin = self.frame.origin
            let size = self.frame.size
            self.alpha = 0
            self.frame.origin = CGPoint(x: origin.x + size.width + 10, y: origin.y)
        })
        viewIsOut = true
    }
    
    func slideIn() {
        UIView.animateWithDuration(1.0, animations: {
            self.frame.origin = self.viewOrigin
            self.alpha = 1.0
        })
        viewIsOut = false
    }
    
}
