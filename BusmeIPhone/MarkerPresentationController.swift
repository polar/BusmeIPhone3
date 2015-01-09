
//
//  MarkerPresentationController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class MarkerPresentationController {
    public var api : BuspassApi
    public var markerBasket : MarkerBasket
    public var currentMarkers : [MarkerInfo] = [MarkerInfo]()
    public var removeMarkers : [MarkerInfo] = [MarkerInfo]()
    public var markerQ : PriorityQueue<MarkerInfo>?
    public var markerPresentationLimit : Int = 10;
    
    public init(api : BuspassApi, markerBasket : MarkerBasket) {
        self.api = api
        self.markerBasket = markerBasket
        markerBasket.markerController = self
    }
    
    func removeFromCurrentMarkers(marker : MarkerInfo) {
        for(var i = 0; i < currentMarkers.count; i++) {
            if (currentMarkers[i] === marker) {
                currentMarkers.removeAtIndex(i)
                return
            }
        }
    }
    
    public func addMarker(marker : MarkerInfo) {
        var replace = false
        var found = false
        let cMarkers = [MarkerInfo](currentMarkers)
        for m in cMarkers {
            if (m.id == marker.id) {
                found = true
                if (m.version < marker.version) {
                    removeMarkers.append(m)
                    removeFromCurrentMarkers(m)
                    replace = true
                }
            }
        }
        for m in markerQ!.getElements() {
            if (m.id == marker.id) {
                found = true
                if (m.version < marker.version) {
                    markerQ!.delete(m)
                    replace = true
                }
            }
        }
        if (replace || found) {
            markerQ!.push(marker)
        }
    }
    
    public func removeMarker(marker : MarkerInfo) {
        removeMarkers.append(marker)
    }
    
    func removeFromRemoveMarkers(marker : MarkerInfo) {
        for(var i = 0; i < currentMarkers.count; i++) {
            if (removeMarkers[i] === marker) {
                removeMarkers.removeAtIndex(i)
                return
            }
        }
    }

    
    public func roll(now : TimeValue64 = UtilsTime.current()) {
        let rMarkers = [MarkerInfo](removeMarkers)
        for marker in rMarkers {
            if marker.displayed {
                marker.onDismiss(true, time: now)
                abandonMarker(marker)
            }
            removeFromRemoveMarkers(marker)
        }
        var backOnQueue : [MarkerInfo] = [MarkerInfo]()
        for m in currentMarkers {
            if (!markerQ!.doesInclude(m)) {
                markerQ!.push(m)
            }
        }
        self.currentMarkers.removeAll(keepCapacity: true)
        var marker = markerQ!.poll()
        while (marker != nil) {
            if (marker!.shouldBeSeen(now)) {
                if (currentMarkers.count < markerPresentationLimit) {
                    if (!marker!.displayed) {
                        currentMarkers.append(marker!)
                        presentMarker(marker!)
                        marker!.onDisplay(now)
                    } else {
                        currentMarkers.append(marker!)
                    }
                } else {
                    if (marker!.displayed) {
                        marker!.onDismiss(true, time: now)
                        abandonMarker(marker!)
                    } else {
                        backOnQueue.append(marker!)
                    }
                }
            } else {
                if (marker!.displayed) {
                    marker!.onDismiss(true, time: now)
                    abandonMarker(marker!)
                }
            }
        }
        for m in backOnQueue {
            markerQ!.push(m)
        }
    }
    
    public func presentMarker(marker : MarkerInfo) {
        let evd = MarkerEventData(markerInfo: marker)
        api.uiEvents.postEvent("MarkerPresent:display", data: evd)
    }
    
    public func abandonMarker(marker : MarkerInfo) {
        let evd = MarkerEventData(markerInfo: marker)
        api.uiEvents.postEvent("MarkerPresent:dismiss", data: evd)
    }
    
    public func onLocationUpdate(location: GeoPoint, time: TimeValue64 = UtilsTime.current()) {
        let markers = markerBasket.getMarkers()
        for marker in markers {
            if marker.shouldBeSeen(time) {
                if (marker.point != nil) {
                    if (marker.radius > 0) {
                        let dist = GeoCalc.getGeoDistance(marker.point!, c2: location)
                        if (dist < marker.radius) {
                            addMarker(marker)
                        } else {
                            removeMarker(marker)
                        }
                    } else {
                        removeMarker(marker)
                    }
                }
            }
        }
    }
}