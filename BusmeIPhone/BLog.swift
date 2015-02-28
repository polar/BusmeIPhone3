//
//  BLog.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class Logger {
    
    let USE_COLORS = false
    
    let DEBUG : Int = 15
    let INFO  : Int = 7
    let WARN  : Int = 3
    let ERROR : Int = 1
    
    var level : Int = BLog.L_DEBUG
    
    var COLORS : [String:[String]] = [String:[String]]();
    
    init(level : Int) {
        self.level = level
        COLORS["default"] = [ "", ""]
        COLORS["red"]     = [ "\u{18}[0;31m", "\u{18}[0m" ]
        COLORS["green"]   = [ "\u{18}[0;32m", "\u{18}[0m" ]
        COLORS["yellow"]  = [ "\u{18}[0;33m", "\u{18}[0m" ]
        COLORS["blue"]    = [ "\u{18}[0;34m", "\u{18}[0m" ]
        COLORS["purple"]  = [ "\u{18}[0;35m", "\u{18}[0m" ]
        COLORS["cyan"]    = [ "\u{18}[0;36m", "\u{18}[0m" ]
    }
    
    func log(message: String,
        function: String = __FUNCTION__,
        file: String = __FILE__,
        line: Int = __LINE__) {
            write("INFO", message: message + " - \(function):\(file):\(line)", color: "default")
    }
    
    func write(label : String, message : String, color : String ) {
        let msg = countElements(message) > 256 ? message.substringToIndex(advance(message.startIndex,256)) : message
        if (USE_COLORS) {
            NSLog("\(COLORS[color]![0])\(label): \(msg)\(COLORS[color]![1])")
        } else {
            NSLog("\(label): \(msg)")
        }
    }
    
    func debug(message: String,
        function: String = __FUNCTION__,
        file: String = __FILE__,
        line: Int = __LINE__) {
        if (level | DEBUG != 0) {
            write("DEBUG", message: message + " - \(function):\(file):\(line)", color: "puple")
        }
    }
    
    func info(message: String,
        function: String = __FUNCTION__,
        file: String = __FILE__,
        line: Int = __LINE__) {
        if (level | INFO != 0) {
            write("INFO", message: message + " - \(function):\(file):\(line)", color: "green")
        }
    }
    
    func warn(message: String,
        function: String = __FUNCTION__,
        file: String = __FILE__,
        line: Int = __LINE__) {
        if (level | WARN != 0) {
            write("WARN", message: message + " - \(function):\(file):\(line)", color: "yellow")
        }
    }
    
    func error(message: String,
        function: String = __FUNCTION__,
        file: String = __FILE__,
        line: Int = __LINE__) {
        if (level | WARN != 0) {
            write("ERROR", message: message + " - \(function):\(file):\(line)", color: "red")
        }
    }
}

struct BLog {
    static let DEALLOC = false
    static let DEBUG = false
    static let ERROR = true
    static let WARN = true
    static let INFO = true
    static let DEBUG_PATTERN = false
    static let DEBUG_NETWORK = true
    
    static let L_DEBUG = 15
    static let L_ERROR =  7
    static let L_WARN  =  3
    static let L_INFO  =  1
    
    static let logger : Logger = Logger(level: L_DEBUG)
}
