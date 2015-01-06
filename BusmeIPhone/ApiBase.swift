//
//  ApiBase.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 12/29/14.
//  Copyright (c) 2014 Polar Humenn. All rights reserved.
//

import Foundation;

public class ApiBase {
    var httpClient: HttpClient
    
    public init(httpClient: HttpClient) {
        self.httpClient = httpClient
    }
    
//    func openURL(url : String) {
//        self.httpClient.openURL(url)
//    }
//    
    public func getURLResponse(url : String) -> HttpResponse {
        return self.httpClient.getURLResponse(url)
    }
    
    
//    func postURL(url : String) {
//        self.httpClient.openURL(url)
//    }
//    
    
    public func postURLResponse(url : String, parameters: [String: AnyObject]) -> HttpResponse {
        return self.httpClient.postURLResponse(url, parameters: parameters)
    }
    
//    
//    func postDeleteURL(url : String) {
//        self.httpClient.postDeleteURL(url)
//    }
    
    public func xmlParse(entity: HttpEntity?) -> Tag? {
        if (entity != nil) {
            let s = entity!.getContent();
            let rxml = RXMLElement.elementFromXMLString(s, encoding: NSUTF8StringEncoding) as RXMLElement;
            return Tag(tag: rxml);
        } else {
            return nil;
        }
    }
}
    
