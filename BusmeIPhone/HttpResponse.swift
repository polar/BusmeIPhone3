//
//  HttpResponse.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 12/29/14.
//  Copyright (c) 2014 Polar Humenn. All rights reserved.
//

import Foundation
import AlamoFire

public class HttpResponse {
    private var response: NSHTTPURLResponse?;
    private var data: AnyObject?;
    private var error: NSError?;
    
    init(response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) {
        self.response = response;
        self.data = data;
        self.error = error;
    }
    
    public func getEntity() -> HttpEntity? {
        if (error != nil) {
            return nil;
        } else {
            return HttpEntity(content: data as String);
        }
    }
    
    public func getStatusLine() -> HttpStatusLine {
        if (error != nil) {
            return HttpStatusLine(statusCode: error!.code, reasonPhrase: error!.description);
        } else {
            return HttpStatusLine(statusCode: 200, reasonPhrase: "Good");
        }
    }
}