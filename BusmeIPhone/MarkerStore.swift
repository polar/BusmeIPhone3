//
//  MarkerStore.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class MarkerStore : Storage {
    
    public var markers : [String:MarkerInfo] = [String:MarkerInfo]()
    
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
    
    public func encodeWithCoder( coder : NSCoder ) {
        coder.encodeObject(markers, forKey: "markers")
    }
    
    public override func preSerialize(api: ApiBase, time: TimeValue64) {
        for marker in markers.values.array {
            marker.preSerialize(api, time: time)
        }
    }
    
    public override func postSerialize(api: ApiBase, time: TimeValue64) {
        for marker in markers.values.array {
            marker.postSerialize(api, time: time)
        }
    }
    
    public func getMarkers() -> [MarkerInfo] {
        return markers.values.array
    }
    
    public func getMarkerInfo(id: String) -> MarkerInfo? {
        return markers[id]
    }
    
    public func empty() {
        self.markers = [String:MarkerInfo]()
    }
    
    public func doesContainMarker(id : String) -> Bool {
        return markers[id] != nil
    }
    
    public func storeMarker(marker : MarkerInfo) {
        markers[marker.id] = marker
    }
    
    public func removeMarker(id : String) {
        let marker = markers[id]
        if marker != nil {
            markers[id] = nil
        }
    }
}