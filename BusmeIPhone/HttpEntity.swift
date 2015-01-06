//
//  HttpEntity.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 12/29/14.
//  Copyright (c) 2014 Polar Humenn. All rights reserved.
//

import Foundation

public class HttpEntity {
    var content: String
    init(content: String) {
        self.content = content
    }
    public func getContent() -> String {
        return self.content
    }
    public func getContentLenght() -> Int {
        return self.content.lengthOfBytesUsingEncoding(NSUTF16StringEncoding)
    }
}