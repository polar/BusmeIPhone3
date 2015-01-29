//
//  MarkerRequestProcessor.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class MarkerRequestProcessor : ArgumentPreparer, ResponseProcessor {
    var markerBasket : MarkerBasket
    
    init(markerBasket : MarkerBasket) {
        self.markerBasket = markerBasket
    }
    
    func getArguments() -> [String : [String]]? {
        var args = [String:[String]]()
        var ids = [String]()
        var versions = [String]()
        for marker in markerBasket.getMarkers() {
            ids.append(marker.getId())
            versions.append("\(marker.version)")
        }
        args["marker_ids"] = ids
        args["marker_versions"] = versions
        return args
    }
    func onResponse(response: Tag) {
        var markers = [String : MarkerInfo]()
        for child in response.childNodes {
            if child.name.lowercaseString == "markers" {
                for bspec in child.childNodes {
                    if bspec.name.lowercaseString == "marker" {
                        if bspec.attributes["destroy"]? == "1" {
                            let id = bspec.attributes["id"]
                            if id != nil {
                                markers[id!] = nil
                            }
                        } else {
                            let marker = MarkerInfo(tag: bspec)
                            if marker.isValid() {
                                markers[marker.getId()] = marker
                            }
                        }
                    }
                }
            }
        }
        for key in markers.keys {
            let marker = markers[key]
            if marker == nil {
                markerBasket.removeMarker(key)
            } else {
                markerBasket.addMarker(marker!)
            }
        }
    }
}