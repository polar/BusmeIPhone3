//
//  IPUtils.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import MapKit

public struct IPUtils {
    public static func mapRectForGeoRect(rect : GeoRect) {
        MKMapRectMake(rect.left, rect.top, rect.right-rect.left, rect.top-rect.bottom);
    }
}