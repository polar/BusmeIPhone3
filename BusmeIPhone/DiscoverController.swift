//
//  DiscoverController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/14/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class DiscoverController : BuspassEventListener {
    public var api : DiscoverApiVersion1
    weak var mainController : MainController?
    
    public var masters = [Master]()
    
    public func getMasters() -> [Master] {
        return masters
    }
    
    public init(mainController : MainController) {
        self.mainController = mainController
        self.api = mainController.api
        registerForEvents()
    }
    
    func registerForEvents() {
        api.bgEvents.registerForEvent("Search:init", listener: self)
        api.bgEvents.registerForEvent("Search:discover", listener: self)
        api.bgEvents.registerForEvent("Search:find", listener: self)
        api.bgEvents.registerForEvent("Search:select", listener: self)
    }
    
    func unregisterForEvents() {
        api.bgEvents.unregisterForEvent("Search:init", listener: self)
        api.bgEvents.unregisterForEvent("Search:discover", listener: self)
        api.bgEvents.unregisterForEvent("Search:find", listener: self)
        api.bgEvents.unregisterForEvent("Search:select", listener: self)
    }
    
    public func onBuspassEvent(event: BuspassEvent) {
        let eventData = event.eventData as? DiscoverEventData
        if eventData != nil {
            if event.eventName == "Search.init" {
                onSearchInitEvent(eventData!)
            } else if event.eventName == "Search:discover" {
                onDiscoverEvent(eventData!)
            } else if event.eventName == "Search:find" {
                onFindEvent(eventData!)
            }
        }
    }
    
    func onSearchInitEvent(eventData : DiscoverEventData) {
        self.masters = [Master]()
        let (status, x) = api.get()
        if (x == nil) {
            eventData.error = status
            eventData.master = nil
            eventData.masters = nil
        }
        api.uiEvents.postEvent("Search:Init:return", data: eventData)
    }
    
    func onDiscoverEvent(eventData : DiscoverEventData) {
        let (status, ms) = api.discover(eventData.loc!.getLongitude(), lat: eventData.loc!.getLatitude(), buffer: eventData.buf!)
        if (status.statusCode != 200) {
            eventData.error = status
            eventData.masters = nil
            eventData.master = nil
        } else {
            for m in ms {
                var found = false
                for master in masters {
                    if master.slug == m.slug {
                        found = true
                        break
                    }
                }
                if !found {
                    masters.append(m)
                }
            }
            eventData.masters = [Master](masters)
        }
        api.uiEvents.postEvent("Search:Discover:return", data: eventData)
    }
    
    func onFindEvent(eventData : DiscoverEventData) {
        let loc = eventData.loc!
        var selectedRect : Rect?
        var selectedMaster : Master?
        for master in masters {
            let rect = Rect(boundingBox: master.bbox!)
            if rect.containsPoint(loc) {
                if selectedRect == nil {
                    selectedRect = rect
                    selectedMaster = master
                } else if (rect.area() < selectedRect!.area()) {
                    selectedRect = rect
                    selectedMaster = master
                }
                
            }
            
        }
        eventData.master = selectedMaster
        api.uiEvents.postEvent("Search:Find:return", data: eventData)
    }
}