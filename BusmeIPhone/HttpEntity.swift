//
//  HttpEntity.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 12/29/14.
//  Copyright (c) 2014 Polar Humenn. All rights reserved.
//

import Foundation

class HttpEntity {
    var content: String
    init(content: String) {
        self.content = content
    }
    func getContent() -> String {
        return self.content
    }
    func getContentLenght() -> Int {
        return self.content.lengthOfBytesUsingEncoding(NSUTF16StringEncoding)
    }
}