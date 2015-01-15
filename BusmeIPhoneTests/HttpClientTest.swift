//
//  HttpClientTest.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/3/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//


import UIKit
import XCTest
import BusmeIPhone


class HttpClientTest: XCTestCase {
    
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
        XCTAssert(response.getStatusLine().statusCode == 200, "Did not Pass");
        XCTAssert(response.getEntity() != nil, "No Entity")
        if (response.getEntity() == nil) {
            return
        }

        XCTAssert(response.getEntity()?.getContent() == "<API version='d1' discover='http://busme-apis.herokuapp.com/apis/d1/discover' master='http://busme-apis.herokuapp.com/apis/d1/master'/>", "Did not get right API structure");
    }
    func testArray() {
        NSLog("Starting testing testArray");
        var eatme = Array<String>();
        XCTAssertEqual(eatme.count, 0, "Not an empty array");
        eatme.append("Eatme");
        XCTAssertEqual(eatme.count, 1, "Expected to have one value");
        NSLog("Finished testing testArray");
    }
    
    func testXMLParse1() {
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

        XCTAssert(response.getEntity()?.getContent() == "<API version='d1' discover='http://busme-apis.herokuapp.com/apis/d1/discover' master='http://busme-apis.herokuapp.com/apis/d1/master'/>", "Did not get right API structure");
        let tag = self.api!.xmlParse(response.getEntity());        XCTAssertNotNil(tag, "Tag empty");
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
        XCTAssert(response.getEntity()?.getContent() == "<API version='d1' discover='http://busme-apis.herokuapp.com/apis/d1/discover' master='http://busme-apis.herokuapp.com/apis/d1/master'/>", "Did not get right API structure");
        let tag = self.api!.xmlParse(response.getEntity());
        let url = tag!.attributes["master"];
        let query = "\(url!)?slug=syracuse-university";
        
        let result: HttpResponse = self.api!.getURLResponse(query);
        let tag2 = self.api!.xmlParse(result.getEntity());
        XCTAssertEqual(tag2!.name, "master", "Not a master");
        XCTAssertEqual(tag2!.childNodes.count, 2, "Wrong number of childNodes");
        var gotit = false;
        for node in tag2!.childNodes {
            NSLog(node.name);
            if (node.name == "title") {
                XCTAssertEqual(node.text!, "Syracuse-University", "Not SU");
                gotit = true;
            }
        }
        XCTAssert(gotit, "Children not found");
        NSLog("We got here");
    }


    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }

}
