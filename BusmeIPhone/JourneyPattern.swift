//
//  JourneyPattern.public var  : String?
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

public class JourneyPattern {
    public var id : String
    public var path : [CLLocationCoordinate2D]?
    public var projectedPath : [MKMapPoint]?
    public var distance : Double?
    public var rect : MKMapRect?
    public var nameid : NameId?
    
    public init(id : String) {
        self.id = id
    }
    
    func initWithCoder(decoder: NSCoder) -> Void {
        self.id = decoder.decodeObjectForKey("id") as String;
        self.nameid = decoder.decodeObjectForKey("nameid") as? NameId
        let ps = decoder.decodeObjectForKey("path") as? [GeoPointImpl]
        if (ps != nil) {
            self.path = toCoordinates(ps!)
        }
        let geoRect  = decoder.decodeObjectForKey("rect") as? GeoRect
        if (geoRect != nil) {
            self.rect = toMapRect(geoRect!);
        }
        
    }
    
    private func toCoordinates(path : [GeoPointImpl]) -> [CLLocationCoordinate2D] {
        var ps = Array<CLLocationCoordinate2D>()
        for p in path {
            ps.append(CLLocationCoordinate2DMake(p.getLatitude(), p.getLongitude()))
        }
        return ps
    }
    
    private func toPath(path : [CLLocationCoordinate2D]) -> [GeoPointImpl] {
        var ps = [GeoPointImpl]()
        for p in path {
            ps.append(GeoPointImpl(lat: p.latitude, lon: p.longitude))
        }
        return ps
    }
    
    private func toGeoRect(mapRect : MKMapRect) -> GeoRect {
        let left = mapRect.origin.x
        let top = mapRect.origin.y
        let right = mapRect.origin.x + mapRect.size.width
        let bottom = mapRect.origin.y + mapRect.size.height
        return GeoRect(left: left, top: top, right: right, bottom: bottom)
    }
    
    private func toMapRect(rect : GeoRect) -> MKMapRect {
        return MKMapRectMake(rect.left, rect.top, rect.right-rect.left, rect.top-rect.bottom);
    }
    
    public func encodeWithCoder( encoder : NSCoder) {
        encoder.encodeObject(id, forKey: "id");
        if (nameid != nil) {
            encoder.encodeObject(nameid!, forKey: "nameid")
        }
        
        if (path != nil) {
            encoder.encodeObject(toPath(path!), forKey: "path")
        }
        if (distance != nil) {
            encoder.encodeDouble(distance!, forKey: "distance")
        }
        if (rect != nil) {
            encoder.encodeObject(toGeoRect(rect!), forKey: "rect")
        }
    }
    
    public func getProjectedPath() -> [MKMapPoint] {
        if (projectedPath == nil) {
            projectedPath = path!.map({
                (x : CLLocationCoordinate2D) in MKMapPointForCoordinate(x)
            })
        }
        return projectedPath!;
    }
    
    public func getPatternNameId() {
        self.nameid = NameId(args: [id, id, "P", "1"])
    }
    
    public func isReady() -> Bool {
        return self.path != nil
    }
    
    public func getDistance() -> Double {
        if (distance == nil) {
            self.distance = GeoPathUtils.getDistance(self.path!)
        }
        return distance!
    }
    
    public func getEndPoint() -> GeoPoint? {
        if (isReady() && path!.count > 0) {
            return path!.last! as GeoPoint
        } else {
            return nil
        }
    }
    
    public func getRect() -> MKMapRect {
        if (rect == nil) {
//            let geoRect = GeoPathUtils.rectForPath(path!);
//            rect = MKMapRectMake(geoRect.left, geoRect.top, geoRect.right-geoRect.left, geoRect.top-geoRect.bottom);
        }
        return rect!;
    }
    
    public func loadParsedXML(tag : Tag) {
        self.id = tag.attributes["id"]!
        let distlit = tag.attributes["distance"]
        if (distlit != nil) {
            self.distance = (distlit! as NSString).doubleValue
        }
        for jps in tag.childNodes {
            if ("jps" == jps.name || "JPS" == jps.name) {
                self.path = parsePath(jps)
                break
            }
        }
    }
    
    private func parsePath(jps : Tag) -> [CLLocationCoordinate2D] {
        var path = [CLLocationCoordinate2D]()
        for jp in jps.childNodes {
            let lat = (jp.attributes["lat"]! as NSString).doubleValue
            let lon = (jp.attributes["lon"]! as NSString).doubleValue
            let gp = CLLocationCoordinate2DMake(lat, lon)
            path.append(gp)
        }
        return path
    }
}