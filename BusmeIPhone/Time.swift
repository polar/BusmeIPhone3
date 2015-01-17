//
//  Time.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation



func cmp(i1 : Int, i2 : Int) -> Int {
    return i1 < i2 ? -1 : i1 == i2 ? 0 : 1
}


func cmp(i1 : Double, i2 : Double) -> Int {
    return i1 < i2 ? -1 : i1 == i2 ? 0 : 1
}


func cmp(i1 : TimeValue64, i2 : TimeValue64) -> Int {
    return i1 < i2 ? -1 : i1 == i2 ? 0 : 1
}

public struct UtilsTime {
    public static func current() -> TimeValue64 {
        let now = Int64(NSDate().timeIntervalSince1970)
        return now
    }
    
    public static func stringForTime(time : TimeValue64) -> String {
        let date_formatter = NSDateFormatter()
        date_formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = NSDate(timeIntervalSince1970: NSTimeInterval(time))
        let today = date_formatter.stringFromDate(date)
        return today
    }
    
    public static func parseInTimeZone(str : String, zone : String) -> TimeValue64 {
        
        let timeZone = NSTimeZone(name: zone)
        NSLog("parseInTimeZone %@ is %@", str, timeZone!)
        
        let date_formatter = NSDateFormatter()
        date_formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        date_formatter.timeZone = timeZone
        let now = NSDate()
        let today = date_formatter.stringFromDate(now)
        NSLog("Today is %@", today)
        let index = advance(today.startIndex, 11)
        let dateT = today.substringToIndex(index) // yyyy-MM-ddT
        
        var xs : [String] = str.componentsSeparatedByString(":")
        if (xs.count < 3) {
            xs.append("00")
        }
        let tstr = String(format: "%@%@:%@:%@", dateT, xs[0], xs[1], xs[2])
        let date : NSDate = date_formatter.dateFromString(tstr)!
        let result = Int64(date.timeIntervalSince1970)
        NSLog("Date for %@ is %@ %d", tstr, date, result)
        return result
    }
}
