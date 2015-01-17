//
//  MasterMainMenu.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/16/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class MasterMainMenu : MenuScreen, MenuDelegate {
    weak var masterController : MasterController?
    weak var mainController : MainController?
    
    func initWithMasterController(masterController : MasterController) -> MasterMainMenu {
        self.masterController = masterController
        self.mainController = masterController.mainController
        initWithMenuData("Menu", menu_data: initMenuData())
        return self
    }
    
    func initMenuData() -> [MenuItem]{
        return [
            reportingMenu(),
            busmeTransitMenu(),
            nearbyMenu(),
            activeMenu(),
            reloadMenu()]
    }
    
    func menuItemSelected(menuItem: MenuItem) -> Bool {
        let action = menuItem.action
        if action == "report" {
            report(menuItem)
        } else if action == "busme" {
            busme(menuItem)
        } else if action == "nearby" {
            nearBy(menuItem)
        } else if action == "active" {
            active(menuItem)
        } else if action == "reload" {
            reload(menuItem)
        }
        return true
    }
    
    func reportingMenu() -> MenuItem {
        let submenu : [MenuItem] = [
            MenuItem(title: "Driver", action: "report", target: self),
            MenuItem(title: "Passenger", action: "report", target: self),
            MenuItem(title: "Stop", action: "report", target: self),
            MenuItem(title: "Login", action: "report", target: self),
            MenuItem(title: "Logout", action: "report", target: self),
            
        ]
        return MenuItem(title: "Reporting", submenu: submenu)
    }

    
    func report(menuItem : MenuItem) {
        let title = menuItem.title
        
        if (BLog.DEBUG) { BLog.logger.debug("Report \(title)") }
        
        if title == "Driver" || title == "Passenger" {
            startReporting(menuItem)
        } else if title == "Stop" {
            stopReporting(menuItem)
        } else if title == "Login" {
            startLogin(menuItem)
        } else if title == "Logout" {
            startLogout(menuItem)
        }
    }
    
    func startLogin(menuItem : MenuItem) {
        if !masterController!.api.isLoggedIn() {
            login(menuItem.title.lowercaseString)
        } else {
            let login = masterController!.api.loginCredentials!
            Toast(title: "Already Logged In", message: "You are already logged in as \(login.roleIntent)", duration : 2).show()
        }
    }
    
    func login(roleIntent : String) {
        let login = Login()
        login.roleIntent = roleIntent
        login.quiet = false
        login.loginTries = 0
        let loginManager = LoginManager(api: masterController!.api)
        let evd = LoginEventData(loginManager: loginManager)
        masterController!.api.bgEvents.postEvent("LoginEvent", data: evd)
    }
    
    func startReporting(menuItem : MenuItem) {
        // TODO
        if true { // masterController!.locationController.getLastKnownLocation() != nil
            if !masterController!.api.isLoggedIn() {
                login(menuItem.title.lowercaseString)
            } else {
                if (title == "Driver" && !masterController!.api.loginCredentials!.hasRole("driver")) {
                    Toast(title: "Not Authorized", message: "You are not logged in as driver", duration: 5).show()
                } else {
                    showSelections(menuItem)
                }
            }
        } else {
            Toast(title: "Need GPS", message: "We have not yet gotten GPS locations from your device", duration: 3).show()
        }
    }
    
    func showSelections(menuItem : MenuItem) {
        Toast(title: "No Selections", message: "There are no journeys within your location", duration: 3).show()
    }
    
    func stopReporting(menuItem : MenuItem) {
        Toast(title: "Stop Reporting", message: "Stop Reporting is not implemented", duration: 3).show()
    }
    
    func startLogout(menuItem : MenuItem) {
        Toast(title: "Logout", message: "Logout is not implemented", duration: 3).show()
    }
    
    func busmeTransitMenu() -> MenuItem {
        let submenu : [MenuItem] = [
            MenuItem(title: "Select", action: "busme", target: self),
            MenuItem(title: "Save As Default", action: "busme", target: self),
            MenuItem(title: "Remove As Default", action: "busme", target: self)
        ]
        return MenuItem(title: "Busme Transit Systems", submenu: submenu)
    }
    
    func busme(menuItem : MenuItem) {
        let title = menuItem.title
        if title == "Select" {
            busmeSelect(menuItem)
        } else if title == "Save As Default" {
            busmeSaveAsDefault(menuItem)
        } else if title == "Remove As Default" {
            busmeRemoveAsDefault(menuItem)
        }
    }
    
    func busmeSelect(menuItem : MenuItem) {
        mainController!.api.uiEvents.postEvent("Main:select", data: MainEventData())
    }
    
    func busmeSaveAsDefault(menuItem : MenuItem) {
        // TODO Possible Error
        let master = masterController!.master
        mainController!.configurator.saveAsDefaultMaster(master)
        Toast(title: "Saved", message: "\(master.name!) is now your default Busme Transit Site", duration: 2).show()
    }
    
    func busmeRemoveAsDefault(menuItem : MenuItem) {
        let master = masterController!.master
        mainController!.configurator.removeAsDefault(master)
        Toast(title: "Removed", message: "\(master.name!) is no longer your default Busme Transit Site. You will be asked to select next time", duration: 2).show()
    }
    
    func nearbyMenu() -> MenuItem {
        let state : VisualState = self.masterController!.journeyVisibilityController.getCurrentState()
        let nearBy : Double = state.nearBy == nil ? 0 : state.nearBy!
        
        let submenu : [MenuItem] = [
            MenuItem(title: "Show All", action: "nearby", target: self, checked: nearBy == 0),
            MenuItem(title: "Only within 2000 feet", action: "nearby", target: self, checked: nearBy == 2000),
            MenuItem(title: "Only within 1000 feet", action: "nearby", target: self, checked: nearBy == 1000),
            MenuItem(title: "Only within 500 feet", action: "nearby", target: self, checked: nearBy == 500)
        ]
        return MenuItem(title: "Near By", submenu: submenu)
    }
    
    func nearBy(menuItem : MenuItem) {
        let title = menuItem.title
        var nearBy : Double = 0
        if title == "Show All" {
            nearBy = 0
        } else if title == "Only within 2000 feet" {
            nearBy = 2000
        } else if title == "Only within 1000 feet" {
            nearBy = 1000
        } else if title == "Only within 500 feet" {
            nearBy = 500
        }
        let state = masterController!.journeyVisibilityController.getCurrentState()
        let stateNearBy = state.nearBy == nil ? 0 : state.nearBy!
        if nearBy != stateNearBy {
            masterController!.journeyVisibilityController.setNearbyState(nearBy)
            masterController!.api.uiEvents.postEvent("VisibilityChanged", data: MainEventData())
            Toast(title : "Nearby Routes", message : nearBy == 0 ? "Now showing all routes" : "Now showing only routes within \(Int(nearBy)) feet.", duration: 1).show()
        }
    }
    
    func activeMenu() -> MenuItem {
        let state : VisualState = self.masterController!.journeyVisibilityController.getCurrentState()
        let onlyActive : Bool = state.onlyActive
        let submenu : [MenuItem] = [
            MenuItem(title: "Show All", action: "active", target: self, checked: !onlyActive),
            MenuItem(title: "Only Active Buses", action: "active", target: self, checked: onlyActive)
        ]
        return MenuItem(title: "Active Buses", submenu: submenu)
    }
    
    func active(menuItem : MenuItem) {
        let title = menuItem.title
        var active = false
        if title == "Show All" {
            active = false
        } else if title == "Only Active Buses" {
            active = true
        }
        let state = masterController!.journeyVisibilityController.getCurrentState()
        if state.onlyActive != active {
            masterController!.journeyVisibilityController.setOnlyActiveState(active)
            masterController!.api.uiEvents.postEvent("VisibilityChanged", data: MainEventData())
            Toast(title : "Active Buses", message : active ? "Now showing only active buses and routes" : "Now showing all routes", duration: 1).show()
        }
    }
    
    func reloadMenu() -> MenuItem {
        let submenu : [MenuItem] = [
            MenuItem(title: "Reload All", action: "reload", target: self),
            MenuItem(title: "Reset Seen Markers", action: "reload", target: self),
            MenuItem(title: "Reset Seen Messages", action: "reload", target: self)
        ]
        return MenuItem(title: "Reload", submenu: submenu)
    }

    func reload(menuItem : MenuItem) {
        let title = menuItem.title
        if title == "Reload All" {
            masterController!.api.bgEvents.postEvent("Master:reload", data: MainEventData())
            masterController!.api.bgEvents.postEvent("JourneySync", data: MainEventData())
            Toast(title: "Reload All", message: "", duration: 1).show()
        } else if title == "Reset Seen Markers" {
            masterController!.api.bgEvents.postEvent("Master:resetSeenMarkers", data: MainEventData())
            Toast(title: "Reset Seen Markers", message: "The markers you have ingored will now reappear when appropriate", duration: 2).show()
        } else if title == "Reset Seen Messages"{
            masterController!.api.bgEvents.postEvent("Master:resetSeenMessages", data: MainEventData())
            Toast(title: "Reset Seen Markers", message: "The message you have removed will now reappear if an when they are appropriate", duration: 2).show()
        }
    }
}