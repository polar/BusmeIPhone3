//
//  JourneyStore.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/5/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class JourneyStore : Storage {
    
    public var journeys : [String:Route] = [String:Route]()
    public var patterns : [String:JourneyPattern] = [String:JourneyPattern]()
    
    override init() {
        super.init()
    }
    public override func initWithCoder( coder : NSCoder) {
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
    
    public func encodeWithCoder( coder : NSCoder ) {
        coder.encodeObject(journeys, forKey: "journeys")
        coder.encodeObject(patterns, forKey: "patterns")
    }
    
    public override func preSerialize(api: ApiBase, time: TimeValue64) {
        for pattern in patterns.values.array {
            pattern.preSerialize(api, time: time)
        }
        for journey in journeys.values.array {
            journey.preSerialize(api, time: time)
        }
    }
    
    public override func postSerialize(api: ApiBase, time: TimeValue64) {
        for pattern in patterns.values.array {
            pattern.postSerialize(api, time: time)
        }
        for journey in journeys.values.array {
            journey.postSerialize(api, time: time)
        }
    }
    
    public func getPattern(id: String) -> JourneyPattern? {
        return patterns[id]
    }
    
    public func getJourney(id: String) -> Route? {
        return journeys[id]
    }
    
    public func empty() {
        for journey in journeys.values.array {
            journey.journeyStore = nil
        }
        journeys = [String:Route]()
        patterns = [String:JourneyPattern]()
    }
    
    public func doesContainPattern(id : String) -> Bool {
        return patterns[id] != nil
    }
    
    public func doesContainJourney(id :String) -> Bool {
        return journeys[id] != nil
    }
    
    public func storePattern(pattern : JourneyPattern) {
        patterns[pattern.id] = pattern
    }
    
    public func storeJourney(journey : Route) {
        journey.journeyStore = self
        journeys[journey.id!] = journey
    }
    
    public func removeJourney(id : String) {
        let journey = journeys[id]
        if journey != nil {
            journey!.journeyStore = nil
            journeys[id] = nil
        }
    }
    
    public func removePattern(id : String) {
        patterns[id] = nil
    }
}