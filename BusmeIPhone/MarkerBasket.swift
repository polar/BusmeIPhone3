//
//  MarkerBasket.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/8/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class MarkerBasket {
    public var markerStore : MarkerStore
    public var markerController : MarkerPresentationController?

    public init(markerStore : MarkerStore) {
        self.markerStore = markerStore
    }
    
    public func empty() {
        for marker in markerStore.getMarkers() {
            markerController?.removeMarker(marker)
        }
        markerStore.empty()
    }
    
    public func getMarkers() -> [MarkerInfo] {
        return markerStore.getMarkers()
    }
    
    public func getMarkerInfo(id : String) -> MarkerInfo? {
        return markerStore.getMarkerInfo(id)
    }
    
    public func resetMarkers(now : TimeValue64 = UtilsTime.current()) {
        for marker in markerStore.getMarkers() {
            marker.reset(time: now)
            markerController?.addMarker(marker)
        }
    }
    
    public func addMarker(marker : MarkerInfo) {
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
    
    public func removeMarker(id : String) {
        let m = markerStore.getMarkerInfo(id)
        if (m != nil) {
            markerStore.removeMarker(m!.id)
            markerController?.removeMarker(m!)
        }
    }
    
    
}