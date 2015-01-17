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
    }
    
    public func legalize(filename : String) -> String {
        var it = filename as NSString
        it = it.stringByReplacingOccurrencesOfString(" ", withString: "_")
        it = it.stringByReplacingOccurrencesOfString("/", withString: "-")
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

        return NSKeyedArchiver.archiveRootObject(store, toFile: legalize(file))
    }
    public func deserializeObjectFromFile(store: Storage, file :String) -> Storage? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(legalize(file)) as? Storage
    }
}