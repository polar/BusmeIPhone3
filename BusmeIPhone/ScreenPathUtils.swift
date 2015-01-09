//
//  ScreenPathUtils.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/9/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation
import CoreGraphics
import MapKit

public struct ScreenPathUtils {
    public static let MAX_ZOOM_LEVEL = 22
    
    public static let EarthRadius : Double = 6378137
    public static let MinLatitude : Double = -85.05112878
    public static let MaxLatitude : Double = 85.05112878
    public static let MinLongitude : Double = -180
    public static let MaxLongitude : Double = 180
    public static let PI : Double = 3.14159
    
    public static let DefaultTileSize : Int = 256
    
    public static var mTileSize = DefaultTileSize
    
    public static func setTileSize( tileSize : Int) {
        mTileSize = tileSize
    }
    public static func clip(n : Double, minValue : Double, maxValue : Double) -> Double {
        return min(max(n,minValue),maxValue)
    }
    public static func getMapSize(levelOfDetail : Int) -> Int {
        return (mTileSize << levelOfDetail)
    }
    public static func getGroundResolution(latitude : Double, levelOfDetail : Int) -> Double {
        let lat = clip(latitude, minValue: MinLatitude, maxValue: MaxLatitude)
        return cos(lat * PI / 180) * 2 * PI * EarthRadius / Double(getMapSize(levelOfDetail))
    }
    public static func getMapScale(latitude : Double, levelOfDetail : Int, screenDpi : Double) -> Double {
        return getGroundResolution(latitude, levelOfDetail: levelOfDetail) * screenDpi / 0.0254
    }
    public static func latLongToPixelXY(latitude : Double, longitude: Double, levelOfDetail : Int, reuse : CGPoint? = nil) -> CGPoint {
        var out = reuse != nil ? reuse! : CGPoint()
        let nw = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        out.x = CGFloat(nw.x)
        out.y = CGFloat(nw.y)
        return out
    }
    public static func pixelXYToLatLong(pixelX : CGFloat, pixelY : CGFloat, levelOfDetail : Int, reuse : GeoPointMutable? = nil) -> GeoPointMutable {
        var out : GeoPointMutable = reuse != nil ? reuse! : GeoPointImpl()
        
        let mapSize = getMapSize(levelOfDetail)
        let x = (clip(Double(pixelX), minValue: 0, maxValue: Double(mapSize - 1)) / Double(mapSize)) - 0.5
        let y = 0.5 - (clip(Double(pixelY), minValue: 0, maxValue: Double(mapSize - 1)) / Double(mapSize))
        
        let latitude = 90 - 360 * atan(exp(-y * 2 * PI)) / PI
        let longitude = 360 * x
        
        
        return out.set(latitude, lon: longitude)
    }
    public static func toScreenPath(geoPoints : [GeoPoint], zoomLevel : Int = MAX_ZOOM_LEVEL) -> [CGPoint] {
        var thePath = [CGPoint]()
        if geoPoints.count > 0 {
            thePath.append(latLongToPixelXY(geoPoints[0].getLatitude(), longitude: geoPoints[0].getLongitude(), levelOfDetail: zoomLevel))
        }
        for point in geoPoints {
            thePath.append(latLongToPixelXY(geoPoints[0].getLatitude(), longitude: geoPoints[0].getLongitude(), levelOfDetail: zoomLevel))
        }
        return thePath
    }
    public static func toProjectedPath(geoPoints : [GeoPoint]) -> [CGPoint] {
        return toReducedScreenPath(geoPoints)
    }
    public static func toReducedScreenPath(geoPoints : [GeoPoint], zoomLevel : Int = MAX_ZOOM_LEVEL) -> [CGPoint] {
        var thePath = [CGPoint]()
        var lastPoint : CGPoint? = nil
        if geoPoints.count > 0 {
            let newPoint = latLongToPixelXY(geoPoints[0].getLatitude(), longitude: geoPoints[0].getLongitude(), levelOfDetail: zoomLevel)
            lastPoint = newPoint
            thePath.append(newPoint)
        }
        for point in geoPoints {
            var newPoint = latLongToPixelXY(geoPoints[0].getLatitude(), longitude: geoPoints[0].getLongitude(), levelOfDetail: zoomLevel)
            if newPoint.x != lastPoint!.x || newPoint.y != lastPoint!.y {
                thePath.append(newPoint)
                lastPoint = newPoint
            }
        }
        return thePath
    }
    
    public func toClippedScreenPath(projectedPath : [MapPoint], projection : Projection) -> CGPath {
        
    }

}