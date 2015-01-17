//
//  HttpClient.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 12/29/14.
//  Copyright (c) 2014 Polar Humenn. All rights reserved.
//

import Foundation
import Alamofire

public class HttpClient {
    public var queue: dispatch_queue_t?
    private var sem : dispatch_semaphore_t = dispatch_semaphore_create(0)
    private var entry : dispatch_semaphore_t = dispatch_semaphore_create(1)
    private var response: HttpResponse?
    
    public init(queue: dispatch_queue_t) {
        self.queue = queue;
    }
    

    public func getURLResponse(url: String) -> HttpResponse {
        Alamofire.request(.GET, url)
            .response(queue: self.queue,  serializer: Request.stringResponseSerializer(encoding: NSUTF8StringEncoding), completionHandler: {(request, response, data, error) in
                dispatch_semaphore_wait(self.entry, DISPATCH_TIME_FOREVER);
                self.response = HttpResponse(response: response, data: data, error: error);
                dispatch_semaphore_signal(self.sem);
            });
        dispatch_semaphore_wait(self.sem, DISPATCH_TIME_FOREVER);
        let result : HttpResponse = self.response!;
        if (result.getStatusLine().statusCode != 200) {
            NSLog("Error %@", result.getStatusLine().reasonPhrase);
        } else {
            NSLog("%@", result.getEntity()!.getContent());
        }
        dispatch_semaphore_signal(self.entry);
        return result;
    }
    
    public func postURLResponse(url: String, parameters: [String: AnyObject]?) -> HttpResponse {
        Alamofire.request(.POST, url, parameters: parameters)
            .response(queue: self.queue,  serializer: Request.stringResponseSerializer(encoding: NSUTF8StringEncoding), completionHandler: {(request, response, data, error) in
                dispatch_semaphore_wait(self.entry, DISPATCH_TIME_FOREVER);
                self.response = HttpResponse(response: response!, data: data, error: error);
                dispatch_semaphore_signal(self.sem);
            });
        
        dispatch_semaphore_wait(self.sem, DISPATCH_TIME_FOREVER);
        let result = self.response;
        dispatch_semaphore_signal(self.entry);
        return result!;
    }
}