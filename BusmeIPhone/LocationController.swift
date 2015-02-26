//
//  LocationController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 2/18/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation

class LocationController : NSObject, CLLocationManagerDelegate {
    
    var mainController : MainController
    var oldLocation : CLLocation?
    var currentLocation : CLLocation?
    var currentGeoPoint : GeoPointImpl?
    var locationManager : CLLocationManager
    
    init(mainController : MainController) {
        self.mainController = mainController
        self.locationManager = CLLocationManager()
        if locationManager.respondsToSelector("requestAlwaysAuthorization") {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.desiredAccuracy = 10
        locationManager.distanceFilter = 10
        
        super.init()
        self.locationManager.delegate = self

        locationManager.startUpdatingLocation()

    }
    
    func restart() {
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
        storeLocation()
    }
    
    func storeLocation() {
        if currentGeoPoint != nil {
            mainController.configurator.setLastLocation(currentGeoPoint!)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        BLog.logger.debug("locations \(locations.count)")
        for loc in locations {
            BLog.logger.debug("\(loc)")
        }
        
        self.oldLocation = self.currentLocation
        self.currentLocation = locations.last as? CLLocation
        self.currentGeoPoint = GeoPointImpl(geoPoint: currentLocation!.coordinate)
        let evd = LocationEventData(
            location: Location(
                name: "\(NSDate())",
                lon: currentGeoPoint!.getLongitude(),
                lat: currentGeoPoint!.getLatitude()))
        mainController.discoverController?.api.uiEvents.postEvent("LocationChanged", data: evd)
        mainController.masterController?.api.uiEvents.postEvent("LocationChanged", data: evd)
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        self.oldLocation = oldLocation
        self.currentLocation = newLocation
        currentGeoPoint = GeoPointImpl(geoPoint: newLocation.coordinate)
        let evd = LocationEventData(
            location: Location(
                name: "\(NSDate())",
                lon: currentGeoPoint!.getLongitude(),
                lat: currentGeoPoint!.getLatitude()))
        mainController.discoverController?.api.uiEvents.postEvent("LocationChanged", data: evd)
        mainController.masterController?.api.uiEvents.postEvent("LocationChanged", data: evd)
    }
}