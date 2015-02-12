//
//  Eatme.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 2/10/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation


struct Eatme {
    static var released = [String]()
    static var jpalloc = 0
    static var jpfreed = 0
    static func add(obj : AnyObject) {
        if BLog.DEALLOC {
            BLog.logger.debug("Dealloc \(reflect(obj).summary)")
            released.append(reflect(obj).summary)
        }
    }
    static var jpids = [String]()
    static func jpAdd(jp: JourneyPattern) {
        if BLog.DEALLOC {
            jpids.append(jp.id)
            jpalloc++
            BLog.logger.debug("JP \(jp.id) allocated alloc \(jpalloc) freed \(jpfreed)")
        }
    }
    static func jpDel(jp: JourneyPattern) {
        if BLog.DEALLOC {
            for (var i = 0; i < jpids.count; i++) {
                if jpids[i] == jp.id {
                    jpids.removeAtIndex(i)
                    jpfreed++
                    BLog.logger.debug("JP \(jp.id) deallocated alloc \(jpalloc) freed \(jpfreed)")
                    return
                }
            }
        }
    }
}