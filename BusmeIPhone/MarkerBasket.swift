//
//  MarkerBasket.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class MarkerBasket {
    unowned var markerStore : MarkerStore
    weak var markerController : MarkerPresentationController?

    init(markerStore : MarkerStore) {
        self.markerStore = markerStore
    }
    
    func empty() {
        for marker in markerStore.getMarkers() {
            markerController?.removeMarker(marker)
        }
        markerStore.empty()
    }
    
    func getMarkers() -> [MarkerInfo] {
        return markerStore.getMarkers()
    }
    
    func getMarkerInfo(id : String) -> MarkerInfo? {
        return markerStore.getMarkerInfo(id)
    }
    
    func resetMarkers(now : TimeValue64 = UtilsTime.current()) {
        for marker in markerStore.getMarkers() {
            marker.reset(time: now)
            markerController?.addMarker(marker)
        }
    }
    
    func addMarker(marker : MarkerInfo) {
        let m = markerStore.getMarkerInfo(marker.id)
        if (m != nil) {
            if (m!.version < marker.version) {
                markerStore.removeMarker(m!.id)
                markerController?.addMarker(marker)
                markerStore.storeMarker(marker)
            }
        } else {
            markerStore.storeMarker(marker)
            markerController?.addMarker(marker)
        }
    }
    
    func removeMarker(id : String) {
        let m = markerStore.getMarkerInfo(id)
        if (m != nil) {
            markerStore.removeMarker(m!.id)
            markerController?.removeMarker(m!)
        }
    }
    
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
    
}