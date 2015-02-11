//
//  ExternalStorageController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class ExternalStorageController {
    var api : BuspassApi
    var available : Bool = true
    var writeable : Bool = true
    var directory : String
    
    init(api : BuspassApi, directory : String) {
        self.api = api
        self.directory = directory
        NSFileManager.defaultManager().createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil, error: nil)
        
    }
    
    func legalize(filename : String) -> String {
        var it = filename as NSString
        it = it.stringByReplacingOccurrencesOfString(" ", withString: "_")
        it = it.stringByReplacingOccurrencesOfString("(", withString: "-")
        it = it.stringByReplacingOccurrencesOfString(")", withString: "-")
        it = it.stringByReplacingOccurrencesOfString("*", withString: ".")
        return it
    }
    
    func isAvailable() -> Bool {
        return available
    }
    func isWriteable() -> Bool {
        return writeable
    }
    func getDirectory() -> String {
        return directory
    }
    func serializeObjectToFile(store: Storage, file : String) -> Bool {
        let legalFilename = legalize(directory + "/" + file)
        let result = NSKeyedArchiver.archiveRootObject(store, toFile: legalFilename)
        return result
    }
    func deserializeObjectFromFile(file :String) -> Storage? {
        let legalFilename = legalize(directory + "/" + file)
        let result : AnyObject? = NSKeyedUnarchiver.unarchiveObjectWithFile(legalFilename)
        let typedResult = result as? Storage
        return typedResult
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}