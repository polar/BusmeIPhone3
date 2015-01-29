//
//  StatusLine.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 12/29/14.
//  Copyright (c) 2014 Polar Humenn. All rights reserved.
//

import Foundation

class HttpStatusLine {
    var statusCode: Int = 0;
    var reasonPhrase: String = "";
    init(statusCode: Int, reasonPhrase: String) {
        self.statusCode = statusCode;
        self.reasonPhrase = reasonPhrase;
    }
    func toString() -> String {
        return "\(statusCode): \(reasonPhrase)"
    }
}