//
//  BusmeIPhoneTests.swift
//  BusmeIPhoneTests
//
//  Created by Polar Humenn on 12/29/14.
//  Copyright (c) 2014 Polar Humenn. All rights reserved.
//

import UIKit
import XCTest
import BusmeIPhone

class BusmeIPhoneTests: XCTestCase {
    var httpQ : dispatch_queue_t = dispatch_queue_create("http", DISPATCH_QUEUE_SERIAL);
    var httpClient : HttpClient?;
    var api : ApiBase?;
    var initialURL : String = "http://busme-apis.herokuapp.com/apis/d1/get";
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.httpClient = HttpClient(queue: self.httpQ);
        self.api = ApiBase(httpClient: self.httpClient!);
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testApiGet() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
        let response: HttpResponse = self.api!.getURLResponse(initialURL);
        XCTAssert(response.getStatusLine().statusCode == 200, "Pass");
        XCTAssert(response.getEntity() != nil, "No Entity")
        if (response.getEntity() == nil) {
            return
        }

        XCTAssert(response.getEntity()!.getContent() == "<API version='d1' discover='http://busme-apis.herokuapp.com/apis/d1/discover' master='http://busme-apis.herokuapp.com/apis/d1/master'/>", "Did not get right API structure");
    }
    
    func testXMLParse() {
        let response: HttpResponse = self.api!.getURLResponse(initialURL);
        XCTAssert(response.getStatusLine().statusCode == 200, "Pass");
        XCTAssert(response.getEntity() != nil, "No Entity")
        if (response.getEntity() == nil) {
            return
        }

        XCTAssert(response.getEntity()!.getContent() == "<API version='d1' discover='http://busme-apis.herokuapp.com/apis/d1/discover' master='http://busme-apis.herokuapp.com/apis/d1/master'/>", "Did not get right API structure");
        let tag = self.api!.xmlParse(response.getEntity());
        XCTAssertNotNil(tag, "Tag empty");
        XCTAssertEqual(tag!.name, "API", "Not right tag");
        let version = tag!.attributes["version"];
        XCTAssertEqual(version!, "d1", "Not right attribute");
        
    }
    
    func testXMLParseStructure() {
        let response: HttpResponse = self.api!.getURLResponse(initialURL);
        XCTAssert(response.getStatusLine().statusCode == 200, "Pass");
        XCTAssert(response.getEntity() != nil, "No Entity")
        if (response.getEntity() == nil) {
            return
        }

        XCTAssert(response.getEntity()!.getContent() == "<API version='d1' discover='http://busme-apis.herokuapp.com/apis/d1/discover' master='http://busme-apis.herokuapp.com/apis/d1/master'/>", "Did not get right API structure");
        let tag = self.api!.xmlParse(response.getEntity());
        let url = tag!.attributes["master"];
        let query = "\(url)/syracuse-university";
        
        let result: HttpResponse = self.api!.getURLResponse(initialURL);
        let tag2 = self.api!.xmlParse(result.getEntity());
        XCTAssertEqual(tag2!.name, "Masters", "Not Masters");
        XCTAssertNotNil(tag2!.childNodes, "Tag empty");
        for node in tag2!.childNodes {
            NSLog("%@", node.name);
        }
        NSLog("We got here");
    }

    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
