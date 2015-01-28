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

public class JourneyPattern : Storage {
    public var id : String = ""
    public var path : [GeoPoint]?
    public var projectedPath : [Point]?
    public var distance : Double?
    public var geoRect : GeoRect?
    public var nameid : NameId?
    
    public init(id : String) {
        super.init()
        self.id = id
    }
    
    public init(tag : Tag) {
        super.init()
        loadParsedXML(tag)
    }
    
    public override init(coder: NSCoder) {
        super.init()
        self.id = coder.decodeObjectForKey("id") as String;
        self.nameid = coder.decodeObjectForKey("nameid") as? NameId
        let ps = coder.decodeObjectForKey("path") as? [GeoPointImpl]
        if (ps != nil) {
            self.path = toCoordinates(ps!)
        }
        self.geoRect  = coder.decodeObjectForKey("rect") as? GeoRect
    }
    
    private func toCoordinates(path : [GeoPointImpl]) -> [GeoPoint] {
        var ps = Array<GeoPoint>()
        for p in path {
            ps.append(CLLocationCoordinate2DMake(p.getLatitude(), p.getLongitude()))
        }
        return ps
    }
    
    private func toPath(path : [GeoPoint]) -> [GeoPointImpl] {
        var ps = [GeoPointImpl]()
        for p in path {
            ps.append(GeoPointImpl(lat: p.getLatitude(), lon: p.getLongitude()))
        }
        return ps
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
        if (geoRect != nil) {
            encoder.encodeObject(geoRect!, forKey: "rect")
        }
    }
    
    public func getProjectedPath() -> [Point] {
        if (projectedPath == nil) {
            self.projectedPath = ScreenPathUtils.toProjectedPath(path!)
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
    
    public func getGeoRect() -> GeoRect {
        if (geoRect == nil) {
            self.geoRect = GeoPathUtils.rectForPath(path!);
        }
        return geoRect!
    }
    
    public func loadParsedXML(tag : Tag) {
        self.id = tag.attributes["id"]!
        let distlit = tag.attributes["distance"]
        if (distlit != nil) {
            self.distance = (distlit! as NSString).doubleValue
        }
        for jps in tag.childNodes {
            if ("jps" == jps.name.lowercaseString) {
                self.path = parsePath(jps)
                break
            }
        }
    }
    
    private func parsePath(jps : Tag) -> [GeoPoint] {
        var path = [GeoPoint]()
        for jp in jps.childNodes {
            let lat = (jp.attributes["lat"]! as NSString).doubleValue
            let lon = (jp.attributes["lon"]! as NSString).doubleValue
            let gp = GeoPointImpl(lat: lat, lon: lon)
            path.append(gp)
        }
        return path
    }
}