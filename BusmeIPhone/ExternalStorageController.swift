//
//  ExternalStorageController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class ExternalStorageController {
    public var api : BuspassApi
    public var available : Bool = true
    public var writeable : Bool = true
    public var directory : String
    
    public init(api : BuspassApi, directory : String) {
        self.api = api
        self.directory = directory
        NSFileManager.defaultManager().createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil, error: nil)
        
    }
    
    public func legalize(filename : String) -> String {
        var it = filename as NSString
        it = it.stringByReplacingOccurrencesOfString(" ", withString: "_")
        it = it.stringByReplacingOccurrencesOfString("(", withString: "-")
        it = it.stringByReplacingOccurrencesOfString(")", withString: "-")
        it = it.stringByReplacingOccurrencesOfString("*", withString: ".")
        return it
    }
    
    public func isAvailable() -> Bool {
        return available
    }
    public func isWriteable() -> Bool {
        return writeable
    }
    public func getDirectory() -> String {
        return directory
    }
    public func serializeObjectToFile(store: Storage, file : String) -> Bool {
        let legalFilename = legalize(directory + "/" + file)
        let result = NSKeyedArchiver.archiveRootObject(store, toFile: legalFilename)
        return result
    }
    public func deserializeObjectFromFile(file :String) -> Storage? {
        let legalFilename = legalize(directory + "/" + file)
        let result : AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithFile(legalFilename)
        let typedResult = result as? Storage
        return typedResult
    }
}