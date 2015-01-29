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

struct ScreenPathUtils {
    static let MAX_ZOOM_LEVEL = 22
    
    static let EarthRadius : Double = 6378137
    static let MinLatitude : Double = -85.05112878
    static let MaxLatitude : Double = 85.05112878
    static let MinLongitude : Double = -180
    static let MaxLongitude : Double = 180
    static let PI : Double = 3.14159
    
    static let DefaultTileSize : Int = 256
    
    static var mTileSize = DefaultTileSize
    
    static func setTileSize( tileSize : Int) {
        mTileSize = tileSize
    }
    static func clip(n : Double, minValue : Double, maxValue : Double) -> Double {
        return min(max(n,minValue),maxValue)
    }
    static func getMapSize(levelOfDetail : Int) -> Int {
        return (mTileSize << levelOfDetail)
    }
    static func getGroundResolution(latitude : Double, levelOfDetail : Int) -> Double {
        let lat = clip(latitude, minValue: MinLatitude, maxValue: MaxLatitude)
        return cos(lat * PI / 180) * 2 * PI * EarthRadius / Double(getMapSize(levelOfDetail))
    }
    static func getMapScale(latitude : Double, levelOfDetail : Int, screenDpi : Double) -> Double {
        return getGroundResolution(latitude, levelOfDetail: levelOfDetail) * screenDpi / 0.0254
    }
    static func latLongToPixelXY(latitude : Double, longitude: Double, levelOfDetail : Int, reuse : PointMutable? = nil) -> PointMutable {
        var out = reuse != nil ? reuse! : PointImpl()
        let lat = clip(latitude, minValue: MinLatitude, maxValue: MaxLatitude)
        let lon = clip(longitude, minValue: MinLongitude, maxValue: MaxLongitude)
        
        let x = (lon + 180.0)/360.0
        let sinLatitude = sin(lat * PI/180.0)
        let y = 0.5 - log(1 + sinLatitude) / (1 - sinLatitude) / (4 * PI)
        let mapSize = getMapSize(levelOfDetail)
        out.setX(clip(x * Double(mapSize) + 0.5, minValue: 0, maxValue: Double(mapSize) - 1.0))
        out.setY(clip(y * Double(mapSize) + 0.5, minValue: 0, maxValue: Double(mapSize) - 1.0))
        return out
    }
    
    // Iphone specific
    static func latLongToProjectedXY(latitude : Double, longitude : Double) -> Point {
        let nw = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        return nw
    }
    static func pixelXYToLatLong(pixelX : CGFloat, pixelY : CGFloat, levelOfDetail : Int, reuse : GeoPointMutable? = nil) -> GeoPointMutable {
        var out : GeoPointMutable = reuse != nil ? reuse! : GeoPointImpl()
        
        let mapSize = getMapSize(levelOfDetail)
        let x = (clip(Double(pixelX), minValue: 0, maxValue: Double(mapSize - 1)) / Double(mapSize)) - 0.5
        let y = 0.5 - (clip(Double(pixelY), minValue: 0, maxValue: Double(mapSize - 1)) / Double(mapSize))
        
        let latitude = 90 - 360 * atan(exp(-y * 2 * PI)) / PI
        let longitude = 360 * x
        
        return out.set(latitude, lon: longitude)
    }
    static func toScreenPath(geoPoints : [GeoPoint], zoomLevel : Int = MAX_ZOOM_LEVEL) -> [Point] {
        var thePath = [Point]()
        if geoPoints.count > 0 {
            thePath.append(latLongToPixelXY(geoPoints[0].getLatitude(), longitude: geoPoints[0].getLongitude(), levelOfDetail: zoomLevel))
        }
        for point in geoPoints {
            thePath.append(latLongToPixelXY(geoPoints[0].getLatitude(), longitude: geoPoints[0].getLongitude(), levelOfDetail: zoomLevel))
        }
        return thePath
    }
    static func toProjectedPath(geoPoints : [GeoPoint]) -> [Point] {
        var thePath = [Point]()
        var lastPoint : Point? = nil
        if geoPoints.count > 0 {
            let newPoint = latLongToProjectedXY(geoPoints[0].getLatitude(), longitude: geoPoints[0].getLongitude())
            lastPoint = newPoint
            thePath.append(newPoint)
        }
        for point in geoPoints {
            var newPoint = latLongToProjectedXY(point.getLatitude(), longitude: point.getLongitude())
            if newPoint.getX() != lastPoint!.getX() || newPoint.getY() != lastPoint!.getY() {
                thePath.append(newPoint)
                lastPoint = newPoint
            }
        }
        return thePath
    }
    static func projectedToScreenPath(projectedPath : [Point], projection : Projection) -> [Point] {
        var ps = [Point]()
        for point in projectedPath {
            ps.append(projection.translatePoint(point))
        }
        return ps
    }
    static func toReducedScreenPath(geoPoints : [GeoPoint], zoomLevel : Int = MAX_ZOOM_LEVEL) -> [Point] {
        var thePath = [Point]()
        var lastPoint : Point? = nil
        if geoPoints.count > 0 {
            let newPoint = latLongToPixelXY(geoPoints[0].getLatitude(), longitude: geoPoints[0].getLongitude(), levelOfDetail: zoomLevel)
            lastPoint = newPoint
            thePath.append(newPoint)
        }
        for point in geoPoints {
            var newPoint = latLongToPixelXY(point.getLatitude(), longitude: point.getLongitude(), levelOfDetail: zoomLevel)
            if newPoint.getX() != lastPoint!.getX() || newPoint.getY() != lastPoint!.getY() {
                thePath.append(newPoint)
                lastPoint = newPoint
            }
        }
        return thePath
    }
    
    static func toClippedScreenPath(projectedPath : [Point], projection : Projection, path: Path? = nil) -> Path {
        var out = path == nil ? Path() : path!
        let rect = projection.screenRect
        var last : Point? = nil
        var reuse = PointImpl()
        var onscreen = false
        if projectedPath.count > 0 {
            last = projection.translatePoint(projectedPath[0])
            onscreen = rect.containsXY(last!.getX(),  y: last!.getY())
        }
        for point in projectedPath {
            var coords = projection.translatePoint(point)
            if last!.getX() != coords.getX() || last!.getY() != coords.getY() {
                if rect.containsXY(coords.getX(), y: coords.getY()) {
                    if !onscreen || out.isEmpty() {
                        out.moveTo(coords.getX(), y: coords.getY())
                    }
                    out.lineTo(coords.getX(), y: coords.getY())
                    onscreen = true
                } else {
                    if onscreen {
                        if out.isEmpty() {
                            out.moveTo(coords.getX(), y: coords.getY())
                        }
                        out.lineTo(coords.getX(), y: coords.getY())
                    } else {
                        let linerect = Rect(left: last!.getX(), top: last!.getY(), right: coords.getX(), bottom: coords.getY())
                        if linerect.intersectRect(rect) {
                            if out.isEmpty() {
                                out.moveTo(coords.getX(), y: coords.getY())
                            }
                            out.lineTo(coords.getX(), y: coords.getY())
                        }
                    }
                }
            } else {
                onscreen = false
            }
            last = coords
        }
        return out
    }
}