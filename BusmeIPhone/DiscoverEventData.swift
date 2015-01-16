//
//  DiscoverEventData.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/13/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

public class DiscoverEventData {
    public var dialog : UIAlertView?
    public var loc : GeoPoint?
    public var buf : Double?
    
    public var master: Master?
    public var masters : [Master]?
    public var error: HttpStatusLine?
    
    public init(master: Master) {
        self.master = master
    }
    
    public init(loc : GeoPoint, buf : Double, dialog : UIAlertView?) {
        self.dialog = dialog
        self.loc = loc
        self.buf = buf
    }
    
    public init(loc : GeoPoint, dialog : UIAlertView?) {
        self.dialog = dialog
        self.loc = loc
    }
}