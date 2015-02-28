//
//  JourneyPostingRecognizer.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 2/26/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class JourneyPostingRecognizer : BuspassEventListener {
    var api : BuspassApi
    var journeyDisplayController : JourneyDisplayController
    var journeyLocationPoster : JourneyLocationPoster
    
    init(api: BuspassApi, journeyDisplayController : JourneyDisplayController, journeyLocationPoster : JourneyLocationPoster) {
        self.api   = api
        self.journeyDisplayController = journeyDisplayController
        self.journeyLocationPoster = journeyLocationPoster
        registerForEvents()
    }
    
    func registerForEvents() {
        api.uiEvents.registerForEvent("LocationChanged", listener: self)
        
        api.bgEvents.registerForEvent("AnalyzeLocation", listener: self)
    }
    
    func unregisterForEvents() {
        api.uiEvents.unregisterForEvent("LocationChanged", listener: self)
        
        api.uiEvents.unregisterForEvent("AnalyzeLocation", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        if event.eventName == "LocationChanged" {
            onLocationChanged(event.eventData as LocationEventData)
        } else if event.eventName == "AnalyzeLocation" {
            onLocationAnalyzed(event.eventData as LocationEventData)
        }
    }
    
    let SPEED_LIMIT = 88.0 / 1000// per milisecond
    
    var locationsPath : [(GeoPoint, TimeValue64)] = []
    
    func add(geoPoint: GeoPoint, time: TimeValue64) {
        let last = locationsPath.last
        if last != nil {
            let (lastPoint, lastTime) = last!
            let dist = GeoCalc.getGeoDistance(lastPoint, c2: geoPoint)
            let diff = time - lastTime
            if 5000 <= diff && dist <= 20000 {
                if dist/Double(diff) < SPEED_LIMIT {
                    locationsPath.append((geoPoint, time))
                } else {
                    locationsPath = []
                }
            }
        } else {
            locationsPath.append((geoPoint, time))
        }
        if locationsPath.count > 5 {
            locationsPath.removeAtIndex(0)
        }
    }
    
    func isQualified(journeyDisplay : JourneyDisplay, geoPoint: GeoPoint, time: TimeValue64) -> Bool {
        let route = journeyDisplay.route
        if route.isJourney() {
            if locationsPath.count > 2 {
                for path in route.getPaths() {
                    var candidates = GeoPathUtils.whereOnPath(path, buffer: route.distanceTolerance, point: geoPoint)
                    for(var i = locationsPath.count-2; i > 0; i--) {
                        let (p,t) = locationsPath[i]
                        let dpoints = GeoPathUtils.whereOnPath(path, buffer: route.distanceTolerance, point: p)
                        var cds : [DGeoPoint] = []
                        for dp in dpoints {
                            for cd in candidates {
                                if dp.index <= cd.index && dp.distance <= cd.distance {
                                    cds.append(dp)
                                }
                            }
                        }
                        candidates = cds
                    }
                    if candidates.count > 0 {
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func onLocationChanged(eventData : LocationEventData) {
        let geoPoint = GeoCalc.toGeoPoint(eventData.location)
        let time = eventData.location.time
        add(geoPoint, time:time)
        if locationsPath.count > 2 {
            if !journeyLocationPoster.isPosting() {
                if api.isLoggedIn() {
                    api.bgEvents.postEvent("AnalyzeLocation", data: eventData)
                }
            }
        }
    }
    
    // Background Thread
    func onLocationAnalyzed(eventData : LocationEventData) {
        let geoPoint = GeoCalc.toGeoPoint(eventData.location)
        let time = eventData.location.time
        let res = qualfiedJourneys(geoPoint, time: time)
        if res.count > 0 {
            let evd = JourneyPostingRecognizerEventData(journeyDisplays: res)
            api.uiEvents.postEvent("JourneyPostingRequest", data: evd)
        }
        
    }
    
    func qualfiedJourneys(geoPoint: GeoPoint, time: TimeValue64) -> [JourneyDisplay] {
        var res : [JourneyDisplay] = []
        if !journeyLocationPoster.isPosting() {
            let js = journeyDisplayController.getJourneyDisplays()
            for journey in js {
                let route = journey.route
                if route.isJourney() {
                    if route.lastKnownLocation != nil {
                        if isQualified(journey, geoPoint: geoPoint, time: time) {
                            res.append(journey)
                        }
                    }
                }
            }
        }
        return res
    }
}