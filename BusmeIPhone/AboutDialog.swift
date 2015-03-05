//
//  AboutDialog.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 2/17/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

class AboutDialog {
    var alertView : UIAlertView
    
    init() {
        var text = "Busme! iOS App v\(APP_VERSION)\n (C) 2008-2015 Adiron, LLC. All Rights Reserved"
        alertView = UIAlertView(title: "About Busme!", message: text, delegate: nil, cancelButtonTitle: "OK")
    }
    
    func show() {
        alertView.show()
    }
}