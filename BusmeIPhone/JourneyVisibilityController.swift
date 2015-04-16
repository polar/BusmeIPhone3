//
//  JourneyVisibilityController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/9/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class VisualState {
    let S_ALL = 1
    let S_ROUTE = 2
    let S_VEHICLE = 3
    
    var state : Int = 1
    var nearBy : Double?
    var onlyActive : Bool = false
    var selectedRoute : JourneyDisplay?
    var selectedRouteCode : String?
    var selectedRouteCodes : NSMutableSet = NSMutableSet()
    var selectedRoutes : NSMutableSet = NSMutableSet()
    var onlySelected : Bool = false
    var selectedLocations :  [GeoPoint] = [GeoPoint]()
    
    init() {
        
    }
    
}

class JourneyVisibilityController : OnJourneyDisplayRemovedListener, OnJourneyDisplayAddedListener, BuspassEventListener {
    let JOURNEY_BY_LOCATION_TOLLERANCE = 200.0
    
    unowned var api : BuspassApi
    unowned var journeyDisplayController : JourneyDisplayController
    
    var nearByDistance : Int = 500
    var currentLocation : GeoPoint?
    
    var stateStack : [VisualState] = [VisualState]()
    
    init(api : BuspassApi, controller : JourneyDisplayController) {
        self.api = api
        self.journeyDisplayController = controller
        controller.onJourneyDisplayAddedListener = self
        controller.onJourneyDisplayRemovedListener = self
        stateStack.append(VisualState())
        registerForEvents()
    }
    
    func registerForEvents() {
        api.uiEvents.registerForEvent("LocationChanged", listener: self)
    }
    
    func unregisterForEvents() {
        api.uiEvents.unregisterForEvent("LocationChanged", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventData = event.eventData as LocationEventData
        currentLocation = GeoPointImpl(lat: eventData.location.latitude, lon: eventData.location.longitude)
    }
    
    func getJourneyDisplays() -> [JourneyDisplay]{
        return journeyDisplayController.getJourneyDisplays()
    }
    
    func getSortedJourneyDisplays() -> [JourneyDisplay] {
        var array = [JourneyDisplay](getJourneyDisplays())
        return array.sorted{(x: JourneyDisplay,y: JourneyDisplay) in x.compareTo(y) < 0}
    }
    
    func getCurrentState() -> VisualState {
        return stateStack.first!
    }
    
    func setNearbyState(nearby  : Double?) {
        let newState = VisualState()
        newState.nearBy = nearby
        newState.onlyActive = stateStack.first!.onlyActive
        self.stateStack = [VisualState]()
        stateStack.insert(newState, atIndex: 0)
        setVisibility(newState)
    }
    
    func setOnlyActiveState(active :Bool) {
        let newState = VisualState()
        newState.onlyActive = active
        newState.nearBy = stateStack.first!.nearBy
        self.stateStack = [VisualState]()
        stateStack.insert(newState, atIndex: 0)
        setVisibility(newState)
    }
    
    func onJourneyDisplayAdded(display: JourneyDisplay) {
        let state = stateStack.first!
        if addJourneyToState(state, display: display) {
            setVisibilityJourneyDisplay(state, display: display)
        } else {
            display.setPathVisible(false)
            display.setNameVisible(false)
        }
        
    }
    func onJourneyDisplayRemoved(journey: JourneyDisplay) {
        journey.setPathVisible(false)
        journey.setNameVisible(false)
        while stateStack.count > 0 && removeJourneyDisplayFromState(stateStack.first!, display: journey) {
            stateStack.removeAtIndex(0)
        }
        if stateStack.count == 0 {
            stateStack.append(VisualState())
        }
        setVisibility(stateStack.first!)
    }
    
    // Should be called when location changes on device. Handles nearby visibilities.
    func onLocationChanged(point : GeoPoint) -> Bool {
        var changed : Bool = false
        self.currentLocation = point
        let state = stateStack.first!
        if state.nearBy != nil {
            switch (state.state) {
            case state.S_ALL, state.S_ROUTE:
                for display in getJourneyDisplays() {
                    var isNearBy = false
                    for path in display.route.getPaths() {
                        if GeoPathUtils.isOnPath(path, buffer: display.route.distanceTolerance, c3: point) {
                            isNearBy = true
                            changed = changed || setVisibilityJourneyDisplay(state, display: display)
                            break
                        }
                    }
                    if !isNearBy {
                        changed = changed || display.isNameVisible()
                        changed = changed || display.isPathVisible()
                        display.setNameVisible(false)
                        display.setPathVisible(false)
                    }
                }
                break
            default:
                break
            }
        }
        return changed
    }
    
    func goBack() {
        if (stateStack.count > 1) {
            stateStack.removeAtIndex(0)
            setVisibility(stateStack.first!)
        }
    }
    
    private var journeysHighlighted = [JourneyDisplay]()
    func highlight(display : JourneyDisplay) {
        if display.route.isRouteDefinition() {
            for jd in display.getActiveJourneys() {
                jd.setNameHighlighted(true)
                jd.setPathHighlighted(true)
                journeysHighlighted.append(jd)
            }
        }
        display.setNameHighlighted(true)
        display.setPathHighlighted(true)
        journeysHighlighted.append(display)
        if (BLog.DEBUG) { BLog.logger.debug("Highlight journeysHighlighted \(journeysHighlighted.count)")}
    }
    
    func unhighlightAll() {
        if (BLog.DEBUG) { BLog.logger.debug("Unhightlight all journeysHighlighted \(journeysHighlighted.count)")}
        for display in journeysHighlighted {
            display.setNameHighlighted(false)
            display.setPathHighlighted(false)
        }
        self.journeysHighlighted = [JourneyDisplay]()
    }
    
    func selectJourneysFromPoint(geoPoint : GeoPoint, buffer : Double) -> [JourneyDisplay] {
        var selected = [JourneyDisplay]()
        for display in getJourneyDisplays() {
            if display.isPathVisible() && display.route.isJourney() {
                var isSelected = false
                for path in display.route.getPaths() {
                    if GeoPathUtils.isOnPath(path, buffer: buffer, c3: geoPoint) {
                        isSelected = true
                        break
                    }
                }
                if isSelected {
                    selected.append(display)
                }
            }
        }
        return selected
    }
    
    func hasCurrentLocation() -> Bool {
        return currentLocation != nil
    }
    
    func getJourneysAtCurrentLocation() -> [JourneyDisplay] {
        if currentLocation != nil {
            return getJourneysByLocation(currentLocation!, buffer: JOURNEY_BY_LOCATION_TOLLERANCE)
        } else {
            return [JourneyDisplay]()
        }
    }
    
    func getJourneysByLocation(geoPoint : GeoPoint, buffer : Double) -> [JourneyDisplay] {
        var selected = [JourneyDisplay]()
        for display in getJourneyDisplays() {
            if display.route.isJourney() {
                var isSelected = false
                for path in display.route.getPaths() {
                    let offPath = GeoPathUtils.offPath(path, point: geoPoint)
                    if BLog.DEBUG { BLog.logger.debug("Path on Route \(display.route.code) is \(offPath) feet from route") }
                    if offPath < buffer {
                        isSelected = true
                        break
                    }
                }
                if isSelected {
                    selected.append(display)
                }
            }
        }
        return selected.sorted{(x: JourneyDisplay,y: JourneyDisplay) in x.compareTo(y) < 0}
    }
    
    func onLocationSelected(geoPoint : GeoPoint) -> Bool {
        var atLeastOneSelected = false
        var selected = [JourneyDisplay]()
        var unselected = [JourneyDisplay]()
        for display in getJourneyDisplays() {
            if display.isPathVisible() {
                var isSelected = false
                for path in display.route.getPaths() {
                    if GeoPathUtils.isOnPath(path, buffer: display.route.distanceTolerance, c3: geoPoint) {
                        isSelected = true
                        break
                    }
                }
                if isSelected {
                    atLeastOneSelected = true
                    selected.append(display)
                } else {
                    unselected.append(display)
                }
            }
        }
        if atLeastOneSelected {
            onSelectionChanged(selected, unselected: unselected, geoPoint: geoPoint)
            return true
        }
        return false
    }
    
    func onSelectionChanged(selected : [JourneyDisplay], unselected : [JourneyDisplay], geoPoint : GeoPoint) {
        var newState = VisualState()
        newState.state = stateStack.first!.state
        newState.nearBy = stateStack.first!.nearBy
        newState.onlyActive = stateStack.first!.onlyActive
        newState.onlySelected = true
        newState.selectedLocations = [GeoPoint](stateStack.first!.selectedLocations)
        newState.selectedLocations.append(geoPoint)
        newState.selectedRoutes = NSMutableSet(set: stateStack.first!.selectedRoutes)
        newState.selectedRoutes.addObjectsFromArray(selected)
        newState.selectedRoutes.minusSet(NSSet(array: unselected))
        newState.selectedRouteCodes = NSMutableSet(set: stateStack.first!.selectedRouteCodes)
        newState.selectedRouteCodes.addObjectsFromArray(selected.map({(x : JourneyDisplay) in x.route.code!}))
        stateStack.insert(newState, atIndex: 0)
        setVisibility(stateStack.first!)
    }
    
    func onVehicleSelected(display : JourneyDisplay) -> Bool {
        var state = stateStack.first!
        if state.state == state.S_VEHICLE {
            if state.selectedRoute === display {
                return false
            } else {
                // We should be at S_ROUTE HERE
                stateStack.removeAtIndex(0)
                assert(stateStack.count > 0)
            }
        }
        var newState = VisualState()
        newState.state = newState.S_VEHICLE
        newState.nearBy = state.nearBy
        newState.onlyActive = state.onlyActive
        newState.selectedRoute = display
        stateStack.insert(newState, atIndex: 0)
        setVisibility(newState)
        return true
        
    }
    
    func onRouteCodeSelected(code : String) -> Bool {
        var state = stateStack.first!
        if state.state == state.S_ROUTE {
            if state.selectedRouteCode == code {
                return false
            } else {
                // We should be at S_ALL HERE?
                stateStack.removeAtIndex(0)
                assert(stateStack.count > 0)
            }
        }
        var newState = VisualState()
        newState.state = newState.S_ROUTE
        newState.nearBy = state.nearBy
        newState.onlyActive = state.onlyActive
        newState.selectedRouteCode = code
        stateStack.insert(newState, atIndex: 0)
        setVisibility(newState)
        return true
        
    }
    
    func addJourneyToState(state : VisualState, display : JourneyDisplay) -> Bool {
        switch (state.state) {
        case state.S_VEHICLE:
            if state.selectedRoute!.route.id! == display.route.id! {
                state.selectedRoute = display
                return true
            }
            return false
        case state.S_ROUTE:
            if nil != state.selectedRoutes.member(display) {
                if state.selectedRouteCode! == display.route.code! {
                    if state.selectedLocations.count == 0 {
                        state.selectedRoutes.addObject(display)
                        return true
                    } else {
                        for point in state.selectedLocations {
                            for path in display.route.getPaths() {
                                if GeoPathUtils.isOnPath(path, buffer: display.route.distanceTolerance, c3: point) {
                                    state.selectedRoutes.addObject(display)
                                    return true
                                }
                            }
                        }
                    }
                }
            }
            return false
        case state.S_ALL:
            if state.onlySelected {
                if nil != state.selectedRoutes.member(display) {
                    if !(state.selectedRouteCodes.count == 0) {
                        state.selectedRoutes.addObject(display)
                        return true
                    } else {
                        for point in state.selectedLocations {
                            for path in display.route.getPaths() {
                                if GeoPathUtils.isOnPath(path, buffer: display.route.distanceTolerance, c3: point) {
                                    state.selectedRoutes.addObject(display)
                                    return true
                                }
                            }
                        }
                    }
                }
            } else {
                return true
            }
            return false
        default:
            if (BLog.ERROR) { BLog.logger.error("Bad Visual State \(state.state)")}
            return false
        }
    }
    
    func removeJourneyDisplayFromState(state :VisualState, display : JourneyDisplay) -> Bool {
        switch (state.state) {
        case state.S_VEHICLE:
            state.selectedRoutes.removeObject(display)
            if state.selectedRoutes.isEqualToSet(NSSet()) {
                return true
            }
            return false
        case state.S_ROUTE:
            state.selectedRoutes.removeObject(display)
            if state.selectedRoutes.isEqualToSet(NSSet()) {
                return true
            }
            if state.onlySelected && state.selectedRoutes.isEqualToSet(NSSet()) {
                return true
            }
            return false
        case state.S_ALL:
            state.selectedRoutes.removeObject(display)
            if display.route.isRouteDefinition() {
                state.selectedRouteCodes.removeObject(display.route.code!)
                
            }
            if state.onlySelected && state.selectedRoutes.isEqualToSet(NSSet()) {
                return true
            }
            return false
        default:
            if (BLog.ERROR) { BLog.logger.error("Bad Visual State \(state.state)")}
            return false
            
        }
    }
    func setVisibility(state : VisualState) {
        switch (state.state) {
        case state.S_ALL, state.S_ROUTE:
            for display in getJourneyDisplays() {
                setVisibilityJourneyDisplay(state, display: display)
            }
            break
        case state.S_VEHICLE:
            var selectedRouteDef : JourneyDisplay? = nil
            for display in getJourneyDisplays() {
                if (selectedRouteDef != nil && selectedRouteDef! === display) {
                    continue
                }
                if state.selectedRoute! === display {
                    if display.route.isJourney() {
                        display.setNameVisible(true)
                        display.setPathVisible(true)
                        selectedRouteDef = display.getRouteDefinition()
                        selectedRouteDef?.setNameVisible(true)
                    }
                } else {
                    display.setNameVisible(false)
                    display.setPathVisible(false)
                }

            }
        default:
            if (BLog.ERROR) { BLog.logger.error("Bad Visual State \(state.state)")}
        }
        
    }
    
    func setVisibilityJourneyDisplay(state : VisualState, display : JourneyDisplay) -> Bool {
        switch (state.state) {
        case state.S_ALL:
            return forS_ALL(state, display: display)
        case state.S_ROUTE:
            return forS_ROUTE(state,display: display)
        case state.S_VEHICLE:
            return forS_VEHICLE(state, display: display)
        default:
            if (BLog.ERROR) { BLog.logger.error("Bad Visual State \(state.state)")}
            return false
        }
    }
    
    func forS_ALL(state :VisualState, display : JourneyDisplay) -> Bool {
        let nameVisible = display.isNameVisible()
        let pathVisible = display.isPathVisible()
        if !state.onlySelected || nil != state.selectedRoutes.member(display) || nil != state.selectedRouteCodes.member(display.route.code!) {
            if display.route.isRouteDefinition() {
                if state.onlyActive {
                    let hasActive = display.hasActiveJourneys()
                    display.setPathVisible(hasActive)
                    display.setNameVisible(hasActive)
                } else {
                    display.setPathVisible(true)
                    display.setNameVisible(true)
                }
            } else if (display.isActive()) {
                display.setNameVisible(false)
                display.setPathVisible(true)
            } else {
                if display.route.isTimeless() {
                    display.setNameVisible(false)
                    display.setPathVisible(true)
                } else {
                    display.setNameVisible(false)
                    display.setPathVisible(false)
                }
            }
        } else {
            display.setPathVisible(false)
            display.setNameVisible(false)
        }
        var changed = pathVisible != display.isPathVisible() || nameVisible != display.isNameVisible()
        return changed
    }
    
    func forS_ROUTE(state : VisualState, display : JourneyDisplay) -> Bool {
        let nameVisible = display.isNameVisible()
        let pathVisible = display.isPathVisible()
        if state.selectedRouteCode! == display.route.code! {
            if display.route.isRouteDefinition() {
                if state.onlyActive {
                    let hasActive = display.hasActiveJourneys()
                    display.setPathVisible(hasActive)
                    display.setNameVisible(hasActive)
                } else {
                    display.setPathVisible(true)
                    display.setNameVisible(true)
                }
            } else if display.isActive() {
                display.setPathVisible(true)
                display.setNameVisible(true)
            } else {
                if display.route.isTimeless() {
                    display.setPathVisible(true)
                    display.setNameVisible(true)
                } else {
                    display.setPathVisible(false)
                    display.setNameVisible(false)
                }
            }
        } else {
            display.setPathVisible(false)
            display.setNameVisible(false)
        }
        var changed = pathVisible != display.isPathVisible() || nameVisible != display.isNameVisible()
        return changed
    }
    
    func forS_VEHICLE(state : VisualState, display : JourneyDisplay) -> Bool {
        let nameVisible = display.isNameVisible()
        let pathVisible = display.isPathVisible()
        if state.selectedRoute === display {
            display.setPathVisible(true)
            display.setNameVisible(true)
        } else {
            display.setPathVisible(false)
            display.setNameVisible(false)
        }
        var changed = pathVisible != display.isPathVisible() || nameVisible != display.isNameVisible()
        return changed
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }


}