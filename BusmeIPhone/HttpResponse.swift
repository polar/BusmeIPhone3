//
//  HttpResponse.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 12/29/14.
//  Copyright (c) 2014 Polar Humenn. All rights reserved.
//

import Foundation
//import AlamoFire

class HttpResponse {
    private var response: NSHTTPURLResponse?;
    private var data: AnyObject?;
    private var error: NSError?;
    
    init(response: NSHTTPURLResponse?, data: AnyObject?, error: NSError?) {
        self.response = response;
        self.data = data;
        self.error = error;
    }
    
    func getEntity() -> HttpEntity? {
        if (error != nil) {
            return nil;
        } else {
            return HttpEntity(content: data as String);
        }
    }
    
    func getStatusLine() -> HttpStatusLine {
        if (error != nil) {
            switch error!.code {
            case -1005, -1009:
                return HttpStatusLine(statusCode: error!.code, reasonPhrase: "Network Error. Please check your wireless/data setup.")
            default:
                return HttpStatusLine(statusCode: error!.code, reasonPhrase: error!.localizedDescription);
            }
        } else {
            return HttpStatusLine(statusCode: 200, reasonPhrase: "Good");
        }
    }
}