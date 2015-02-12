//
//  JourneyPattern.var  : String?
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class JourneyPattern : Storage {
    var id : String = ""
    var path : [GeoPoint]?
    var projectedPath : [Point]?
    var distance : Double?
    var geoRect : GeoRect?
    var nameid : NameId?
    
    init(id : String) {
        super.init()
        self.id = id
        Eatme.jpAdd(self)
    }
    
    init(tag : Tag) {
        super.init()
        loadParsedXML(tag)
        Eatme.jpAdd(self)
    }
    
    override init(coder: NSCoder) {
        super.init()
        self.id = coder.decodeObjectForKey("id") as String;
        self.nameid = coder.decodeObjectForKey("nameid") as? NameId
        self.distance = coder.decodeDoubleForKey("distance")
        let ps = coder.decodeObjectForKey("path") as? [GeoPointImpl]
        if (ps != nil) {
            self.path = toCoordinates(ps!)
        }
        self.geoRect  = coder.decodeObjectForKey("rect") as? GeoRect
        Eatme.jpAdd(self)
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
    
    func encodeWithCoder( encoder : NSCoder) {
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
    
    func getProjectedPath() -> [Point] {
        if (projectedPath == nil) {
            self.projectedPath = ScreenPathUtils.toProjectedPath(path!)
        }
        return projectedPath!;
    }
    
    func isReady() -> Bool {
        return self.path != nil
    }
    
    func getDistance() -> Double {

        if (distance == nil) {
            self.distance = GeoPathUtils.getDistance(self.path!)
        }
        return distance!
    }
    
    func getEndPoint() -> GeoPoint? {

        if (isReady() && path!.count > 0) {
            return path!.last! as GeoPoint
        } else {
            return nil
        }
    }
    
    func getGeoRect() -> GeoRect {

        if (geoRect == nil) {
            self.geoRect = GeoPathUtils.rectForPath(path!);
        }
        return geoRect!
    }
    
    func loadParsedXML(tag : Tag) {
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
    
    deinit {
        Eatme.jpDel(self)
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC JourneyPattern \(id)") }
    }
}