//
//  BLog.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class Logger {
    
    public let USE_COLORS = false
    
    public let DEBUG : Int = 15
    public let INFO  : Int = 7
    public let WARN  : Int = 3
    public let ERROR : Int = 1
    
    public var level : Int = BLog.L_DEBUG
    
    public var COLORS : [String:[String]] = [String:[String]]();
    
    public init(level : Int) {
        self.level = level
        COLORS["default"] = [ "", ""]
        COLORS["red"]     = [ "\u{18}[0;31m", "\u{18}[0m" ]
        COLORS["green"]   = [ "\u{18}[0;32m", "\u{18}[0m" ]
        COLORS["yellow"]  = [ "\u{18}[0;33m", "\u{18}[0m" ]
        COLORS["blue"]    = [ "\u{18}[0;34m", "\u{18}[0m" ]
        COLORS["purple"]  = [ "\u{18}[0;35m", "\u{18}[0m" ]
        COLORS["cyan"]    = [ "\u{18}[0;36m", "\u{18}[0m" ]
    }
    
    public func log(message: String,
        function: String = __FUNCTION__,
        file: String = __FILE__,
        line: Int = __LINE__) {
            write("INFO", message: message + " - \(function):\(file):\(line)", color: "default")
    }
    
    public func write(label : String, message : String, color : String ) {
        if (USE_COLORS) {
            NSLog("\(COLORS[color]![0])\(label): \(message)\(COLORS[color]![1])")
        } else {
            NSLog("\(label): \(message)")
        }
    }
    
    public func debug(message: String,
        function: String = __FUNCTION__,
        file: String = __FILE__,
        line: Int = __LINE__) {
        if (level | DEBUG != 0) {
            write("DEBUG", message: message + " - \(function):\(file):\(line)", color: "puple")
        }
    }
    
    public func info(message: String,
        function: String = __FUNCTION__,
        file: String = __FILE__,
        line: Int = __LINE__) {
        if (level | INFO != 0) {
            write("INFO", message: message + " - \(function):\(file):\(line)", color: "green")
        }
    }
    
    public func warn(message: String,
        function: String = __FUNCTION__,
        file: String = __FILE__,
        line: Int = __LINE__) {
        if (level | WARN != 0) {
            write("WARN", message: message + " - \(function):\(file):\(line)", color: "yellow")
        }
    }
    
    public func error(message: String,
        function: String = __FUNCTION__,
        file: String = __FILE__,
        line: Int = __LINE__) {
        if (level | WARN != 0) {
            write("ERROR", message: message + " - \(function):\(file):\(line)", color: "red")
        }
    }
}

public struct BLog {
    public static let DEBUG = false
    public static let ERROR = true
    public static let WARN = true
    public static let INFO = true
    public static let DEBUG_PATTERN = false
    
    public static let L_DEBUG = 15
    public static let L_ERROR =  7
    public static let L_WARN  =  3
    public static let L_INFO  =  1
    
    public static let logger : Logger = Logger(level: L_DEBUG)
}
