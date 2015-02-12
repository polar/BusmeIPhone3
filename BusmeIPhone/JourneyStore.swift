//
//  JourneyStore.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class JourneyStore : Storage {
    var name: String
    
    var journeys : [String:Route] = [String:Route]()
    var patterns : [String:JourneyPattern] = [String:JourneyPattern]()
    
    init(name: String) {
        self.name = name
        super.init()
    }
    override init( coder : NSCoder) {
        let name = coder.decodeObjectForKey("name") as? String
        if name == nil {
            self.name = "unknown"
        } else{
            self.name = name!
        }
        super.init()
        let journeys = coder.decodeObjectForKey("journeys") as? [String:Route]
        if journeys != nil {
            self.journeys = journeys!
        }
        
        let patterns = coder.decodeObjectForKey("patterns") as? [String:JourneyPattern]
        if patterns != nil {
            self.patterns = patterns!
        }
        for journey in self.journeys.values.array {
            journey.journeyStore = self
        }
    }
    
    func encodeWithCoder( coder : NSCoder ) {
        coder.encodeObject(name, forKey: "name")
        coder.encodeObject(journeys, forKey: "journeys")
        coder.encodeObject(patterns, forKey: "patterns")
    }
    
    override func preSerialize(api: ApiBase, time: TimeValue64) {
        for pattern in patterns.values.array {
            pattern.preSerialize(api, time: time)
        }
        for journey in journeys.values.array {
            journey.preSerialize(api, time: time)
        }
    }
    
    override func postSerialize(api: ApiBase, time: TimeValue64) {
        for pattern in patterns.values.array {
            pattern.postSerialize(api, time: time)
        }
        for journey in journeys.values.array {
            journey.postSerialize(api, time: time)
        }
    }
    
    func getPattern(id: String) -> JourneyPattern? {
        return patterns[id]
    }
    
    func getJourney(id: String) -> Route? {
        return journeys[id]
    }
    
    func empty() {
        for journey in journeys.values.array {
            journey.journeyStore = nil
        }
        journeys = [String:Route]()
        patterns = [String:JourneyPattern]()
    }
    
    func doesContainPattern(id : String) -> Bool {
        return patterns[id] != nil
    }
    
    func doesContainJourney(id :String) -> Bool {
        return journeys[id] != nil
    }
    
    func storePattern(pattern : JourneyPattern) {
        patterns[pattern.id] = pattern
    }
    
    func storeJourney(journey : Route) {
        journey.journeyStore = self
        journeys[journey.id!] = journey
    }
    
    func removeJourney(id : String) {
        let journey = journeys[id]
        if journey != nil {
            journey!.journeyStore = nil
            journeys[id] = nil
        }
    }
    
    func removePattern(id : String) {
        patterns[id] = nil
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC JourneyStore(\(name)) deallocated with \(patterns.count) patterns \(journeys.count) journeys") }
    }
}