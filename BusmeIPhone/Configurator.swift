//
//  Configurator.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/14/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation

public class Configurator {
    
    public func getCacheDirectory() -> String {
        let directories = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask,true)
        let cache_directory = directories[0] as NSString
        let directory = cache_directory + "/com.busme"
        return directory
    }
    
    public func getDefaultMaster() -> Master? {
        if BLog.DEBUG { BLog.logger.debug("Getting Default Master") }
        let result: AnyObject? = NSUserDefaults.standardUserDefaults().objectForKey("DefaultMaster")
        if result != nil {
            let data = result as? NSData
            if data != nil {
                let master = NSKeyedUnarchiver.unarchiveObjectWithData(data!) as? Master
                if BLog.DEBUG { BLog.logger.debug("Got Default Master \(master?.slug)") }
                return master
            }
        }
        if BLog.DEBUG { BLog.logger.debug("No Default Master") }
        return nil
    }
    
    public func setLastLocation(location : GeoPoint) {
        let loc = GeoPointImpl(lat: location.getLatitude(), lon: location.getLongitude())
        if BLog.DEBUG { BLog.logger.debug("Saving Last Location \(loc)") }
        NSUserDefaults.standardUserDefaults().setObject(loc, forKey: "LastLocation")
    }
    
    public func getLastLocation() -> GeoPoint? {
        return NSUserDefaults.standardUserDefaults().objectForKey("LastLocation") as? GeoPointImpl
    }
    
    public func saveAsDefaultMaster(master : Master)  {
        if BLog.DEBUG { BLog.logger.debug("Saving Default Mater \(master.name)") }
        let result = NSKeyedArchiver.archivedDataWithRootObject(master)
        NSUserDefaults.standardUserDefaults().setObject(result, forKey: "DefaultMaster")
    }
    
    public func removeAsDefault(master : Master) {
        NSUserDefaults.standardUserDefaults().removeObjectForKey("DefaultMaster")
    }
}