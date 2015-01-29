//
//  DiscoverEventData.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/13/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

class DiscoverEventData {
    var dialog : UIAlertView?
    var loc : GeoPoint?
    var buf : Double?
    
    var master: Master?
    var masters : [Master]?
    var error: HttpStatusLine?
    
    init() {
    }
    
    init(dialog : UIAlertView) {
        self.dialog = dialog
    }
    
    init(master: Master) {
        self.master = master
    }
    
    init(loc : GeoPoint, buf : Double, dialog : UIAlertView?) {
        self.dialog = dialog
        self.loc = loc
        self.buf = buf
    }
    
    init(loc : GeoPoint, dialog : UIAlertView?) {
        self.dialog = dialog
        self.loc = loc
    }
}