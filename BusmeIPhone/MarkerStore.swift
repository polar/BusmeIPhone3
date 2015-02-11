//
//  MarkerStore.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class MarkerStore : Storage {
    
    var markers : [String:MarkerInfo] = [String:MarkerInfo]()
    
    override init() {
        super.init()
    }
    override init( coder : NSCoder) {
        super.init()
        let markers = coder.decodeObjectForKey("markers") as? [String:MarkerInfo]
        if markers != nil {
            self.markers = markers!
        }
    }
    
    func encodeWithCoder( coder : NSCoder ) {
        coder.encodeObject(markers, forKey: "markers")
    }
    
    override func preSerialize(api: ApiBase, time: TimeValue64) {
        for marker in markers.values.array {
            marker.preSerialize(api, time: time)
        }
    }
    
    override func postSerialize(api: ApiBase, time: TimeValue64) {
        for marker in markers.values.array {
            marker.postSerialize(api, time: time)
        }
    }
    
    func getMarkers() -> [MarkerInfo] {
        return markers.values.array
    }
    
    func getMarkerInfo(id: String) -> MarkerInfo? {
        return markers[id]
    }
    
    func empty() {
        self.markers = [String:MarkerInfo]()
    }
    
    func doesContainMarker(id : String) -> Bool {
        return markers[id] != nil
    }
    
    func storeMarker(marker : MarkerInfo) {
        markers[marker.id] = marker
    }
    
    func removeMarker(id : String) {
        let marker = markers[id]
        if marker != nil {
            markers[id] = nil
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}