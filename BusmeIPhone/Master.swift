//
//  Master.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/7/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class Master : NSObject {
    var lon : Double?
    var lat : Double?
    var slug : String?
    var name : String?
    var apiUrl : String?
    var title : String?
    var masterDescription : String?
    var bbox : BoundingBox?
    var timeFormat : String = "%l:%M %P"
    
    init( coder : NSCoder ) {
        super.init()
        initWithCoder(coder)
    }
    
    init(tag : Tag) {
        super.init()
        loadParsedXML(tag)
    }

    func initWithCoder(coder : NSCoder) {
        self.lon = coder.decodeDoubleForKey("lon")
        self.lat = coder.decodeDoubleForKey("lat")
        self.slug = coder.decodeObjectForKey("slug") as? String
        self.name = coder.decodeObjectForKey("name") as? String
        self.masterDescription = coder.decodeObjectForKey("description") as? String
        self.apiUrl = coder.decodeObjectForKey("apiUrl") as? String
        
        self.bbox = coder.decodeObjectForKey("bbox") as? BoundingBox
        self.title = coder.decodeObjectForKey("title") as? String
        self.timeFormat = coder.decodeObjectForKey("timeFormat") as String
    }
    
    func encodeWithCoder(coder : NSCoder) {
        coder.encodeDouble(lon!, forKey: "lon")
        coder.encodeDouble(lat!, forKey: "lat")
        coder.encodeObject(slug!, forKey: "slug")
        coder.encodeObject(name!, forKey: "name")
        coder.encodeObject(apiUrl!, forKey: "apiUrl")
        coder.encodeObject(bbox!, forKey: "bbox")
        coder.encodeObject(title!, forKey: "title")
        coder.encodeObject(masterDescription!, forKey: "description")
        coder.encodeObject(timeFormat, forKey: "timeFormat")
    }
    
    func loadParsedXML(tag : Tag) {
        let lon = tag.attributes["lon"]
        let lat = tag.attributes["lat"]
        self.slug = tag.attributes["slug"]
        self.name = tag.attributes["name"]
        self.apiUrl = tag.attributes["api"]
        let bounds = tag.attributes["bounds"]
        if bounds != nil {
            let bs = bounds!.componentsSeparatedByString(",")
            if bs.count == 4 {
                self.bbox = BoundingBox(array: bs)
            }
        }
        if (lon != nil) {
            self.lon = (lon! as NSString).doubleValue
        }
        if (lat != nil) {
            self.lat = (lat! as NSString).doubleValue
        }
        for child in tag.childNodes {
            if ("title" == child.name.lowercaseString) {
                self.title = child.text
            }
            if ("description" == child.name.lowercaseString) {
                self.masterDescription = child.text
            }
        }
    }
    
    func isValid() -> Bool {
        return lon != nil && lat != nil && name != nil && slug != nil && title != nil && apiUrl != nil && masterDescription != nil && bbox != nil
    }
    
    func toString() -> String {
        return "<Master slug=\(slug) lon=\(lon) lat=\(lat) name=\(name) url=\(apiUrl)>"
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC Master \(slug!)") }
    }
    
    
}