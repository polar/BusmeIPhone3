//
//  TimeTest.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/6/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//


import UIKit
import XCTest
import BusmeIPhone


class TimeTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTimeDate() {
        let time1 = UtilsTime.parseInTimeZone("0:00:01", zone: "America/New_York")
        let time2 = UtilsTime.parseInTimeZone("0:00:02", zone: "America/New_York")
        
        NSLog("time1 is %d, time2 is %d", time1, time2)
        XCTAssertEqual(time1 + 1 , time2, "Times should be one second from each other");
    }
    
    func testTimeZone() {
        let time1 = UtilsTime.parseInTimeZone("0:00:00", zone: "America/New_York")
        let time2 = UtilsTime.parseInTimeZone("0:00:00", zone: "America/Denver")
        
        NSLog("time1 is %d, time2 is %d", time1, time2)
        XCTAssertEqual(time1 + 2 * 60 * 60 , time2, "Times should be two hours from each other");
    }
}