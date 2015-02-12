
//
//  MarkerPresentationController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class MarkerComparator : Comparator {
    func compare(lhs: AnyObject, rhs: AnyObject) -> Int {
        return compare(lhs as MarkerInfo, m2: rhs as MarkerInfo)
    }
    
    func compare(m1 : MarkerInfo, m2 : MarkerInfo) -> Int {
        let now = UtilsTime.current()
        let priority = cmp(m1.priority, m2.priority)
        if priority == 0 {
            return cmp(m1.nextTime(now), m2.nextTime(now))
        }
        return priority
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
    
}

class MarkerPresentationController {
    unowned var api : BuspassApi
    unowned var markerBasket : MarkerBasket
    var currentMarkers : [MarkerInfo] = [MarkerInfo]()
    var removeMarkers : [MarkerInfo] = [MarkerInfo]()
    var markerQ : PriorityQueue<MarkerInfo>!
    var markerPresentationLimit : Int = 10;
    
    init(api : BuspassApi, markerBasket : MarkerBasket) {
        self.api = api
        self.markerBasket = markerBasket
        markerBasket.markerController = self
        self.markerQ = PriorityQueue<MarkerInfo>(compare: MarkerComparator())
    }
    
    func removeFromCurrentMarkers(marker : MarkerInfo) {
        for(var i = 0; i < currentMarkers.count; i++) {
            if (currentMarkers[i] === marker) {
                currentMarkers.removeAtIndex(i)
                return
            }
        }
    }
    
    func addMarker(marker : MarkerInfo) {
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
        for m in markerQ.getElements() {
            if (m.id == marker.id) {
                found = true
                if (m.version < marker.version) {
                    markerQ.delete(m)
                    replace = true
                }
            }
        }
        if (replace || !found) {
            markerQ.push(marker)
        }
    }
    
    func removeMarker(marker : MarkerInfo) {
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
    
    func onDismiss(remind: Bool, markerInfo: MarkerInfo, time : TimeValue64) {
        markerInfo.onDismiss(remind)
        if !remind {
            // This means remove it
            removeFromCurrentMarkers(markerInfo)
        }
    }

    
    func roll(now : TimeValue64 = UtilsTime.current()) {
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
            if (!markerQ.doesInclude(m)) {
                markerQ.push(m)
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
            marker = markerQ!.poll()
        }
        for m in backOnQueue {
            markerQ.push(m)
        }
    }
    
    func presentMarker(marker : MarkerInfo) {
        let evd = MarkerEventData(markerInfo: marker)
        api.uiEvents.postEvent("MarkerPresent:display", data: evd)
    }
    
    func abandonMarker(marker : MarkerInfo) {
        let evd = MarkerEventData(markerInfo: marker)
        api.uiEvents.postEvent("MarkerPresent:dismiss", data: evd)
    }
    
    // Done on Background
    
    func onLocationUpdate(location: GeoPoint, time: TimeValue64 = UtilsTime.current()) {
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
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}