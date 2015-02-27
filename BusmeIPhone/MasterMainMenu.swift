//
//  MasterMainMenu.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/16/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

class MasterMainMenu : MenuScreen, MenuDelegate {
    weak var masterController : MasterController?
    weak var mainController : MainController?
    weak var masterMapScreen : MasterMapScreen?
    
    func initWithMasterMapScreen(masterMapScreen : MasterMapScreen) -> MasterMainMenu {
        self.masterMapScreen = masterMapScreen
        return initWithMasterController(masterMapScreen.masterController)
    }
    
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
        } else if action == "recognize" {
            recognize(menuItem)
        }
        return true
    }
    
    func reportingMenu() -> MenuItem {
        var submenu : [MenuItem] = [
            MenuItem(title: "Driver", action: "report", target: self),
            MenuItem(title: "Passenger", action: "report", target: self),
            MenuItem(title: "Stop", action: "report", target: self),
            MenuItem(title: "Login", action: "report", target: self),
            MenuItem(title: "Logout", action: "report", target: self),
            MenuItem(title: "Register", action: "report", target: self),
            MenuItem(title: "Forget Me", action: "report", target: self),
            
        ]
        if BLog.DEBUG {
            submenu.append(
                MenuItem(title: "Test:Recognizer", action: "recognize", target: self))
        }
        return MenuItem(title: "Reporting", submenu: submenu)
    }

    func recognize(menuItem: MenuItem) {
        // Toggle off if needed
        if masterMapScreen?.testLocationController?.selectedRoute != nil {
            masterMapScreen!.testLocationController!.selectedRoute = nil
            Toast(title: "Test Recognizer", message: "No longer testing", duration: 3).show()
            menuItem.navigationController?.popToRootViewControllerAnimated(true)
            return
        }
        
        let now = UtilsTime.current()
        // Just select the first one.
        var journey : JourneyDisplay?
        for jd in masterController!.journeyDisplayController.getJourneyDisplays() {
            if jd.route.isJourney() && jd.route.getStartTime() < now && now < jd.route.getEndTime() {
                if jd.route.lastLocationUpdate != nil {
                    let diff = UtilsTime.current() - jd.route.lastLocationUpdate!
                    if diff < 10000 {
                        let route = jd.route
                        let startT = UtilsTime.hhmmaForTime(route.getStartTime())
                        let endT = UtilsTime.hhmmaForTime(route.getEndTime())
                        let msg = "Trying to recognize \(route.name!) \(startT) - \(endT)"
                        Toast(title: "Test Recognizer", message: msg, duration: 3).show()
                        masterMapScreen?.testLocationController?.selectedRoute = jd.route
                    }
                }
            }
        }
        menuItem.navigationController?.popToRootViewControllerAnimated(true)
        
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
        } else if title == "Register" {
            startRegister(menuItem)
        } else if title == "Forget Me" {
            forgetMe(menuItem)
        }
    }
    
    func startRegister(menuItem : MenuItem) {
        if masterController!.api.isLoggedIn() {
            let login = masterController!.api.loginCredentials!
            UIAlertView(title: "Already Logged In", message: "You are already logged in as \(login.roleIntent). Please log out before trying to create a new user", delegate: nil, cancelButtonTitle: "OK").show()
        } else {
            register(menuItem)
        }
    }
    
    func startLogin(menuItem : MenuItem) {
        if !masterController!.api.isLoggedIn() {
            login(menuItem)
        } else {
            let login = masterController!.api.loginCredentials!
            Toast(title: "Already Logged In", message: "You are already logged in as \(login.roleIntent)", duration : 2).show()
        }
    }
    
    func login(menuItem: MenuItem) {
        let roleIntent = menuItem.title.lowercaseString
        let login = Login()
        login.roleIntent = roleIntent
        login.quiet = false
        login.loginTries = 0
        let loginManager = LoginManager(api: masterController!.api)
        var loginControllr = LoginFormController(loginManager: loginManager)
        menuItem.navigationController?.pushViewController(loginControllr, animated: true)
    }
    
    func register(menuItem: MenuItem) {
        let login = Login()
        login.quiet = false
        let loginManager = LoginManager(api: masterController!.api)
        var loginController = RegisterFormController(loginManager: loginManager)
        menuItem.navigationController?.pushViewController(loginController, animated: true)
    }
    
    func forgetMe(menuItem: MenuItem) {
        let evd = JourneyEventData(reason: JourneyEvent.R_FORCED)
        masterController?.api.bgEvents.postEvent("JourneyStopPosting", data: evd)
        navigationController?.popToRootViewControllerAnimated(true)
        if (masterController?.api.isLoggedIn() != nil) {
            let evd1 = LoginEventData(loginManager: masterController!.api.loginManager!)
            masterController?.api.bgEvents.postEvent("Logout", data: evd1)
        }
        let slug = masterController?.master.slug
        if slug != nil {
            MasterLogin.forget(slug!)
        }
        Toast(title: "Forget Me", message: "Your Busme! identity and credentials have been removed from the device.", duration: 3).show()
    }
    
    func startReporting(menuItem : MenuItem) {
        // TODO
        if true { // masterController!.locationController.getLastKnownLocation() != nil
            if !masterController!.api.isLoggedIn() {
                login(menuItem)
            } else {
                if (menuItem.title == "Driver" && !masterController!.api.loginCredentials!.hasRole("driver")) {
                    Toast(title: "Not Authorized", message: "You are authorized as a driver", duration: 5).show()
                } else {
                    showSelections(menuItem)
                }
            }
        } else {
            Toast(title: "Need GPS", message: "We have not yet gotten GPS locations from your device", duration: 3).show()
        }
    }
    
    func showSelections(menuItem : MenuItem) {
        if (!masterController!.journeyVisibilityController.hasCurrentLocation()) {
            Toast(title: "No Location", message: "We do not have a GPS location for your device. Please try later", duration: 4).show()
            menuItem.navigationController?.popToRootViewControllerAnimated(true)
        } else {
            let role = menuItem.title == "Driver" ? "driver" : "passenger"
            var jds = masterController!.journeyVisibilityController.getJourneysAtCurrentLocation()
            if jds.count > 0 {
                var viewController = JourneyPostingSelectionView(api: masterController!.api, role: role, journeyDisplays: jds)
                menuItem.navigationController?.pushViewController(viewController, animated: true)
            } else {
                Toast(title: "No Selections", message: "There are no journeys within your location", duration: 3).show()
                menuItem.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    func stopReporting(menuItem : MenuItem) {
        let evd = JourneyEventData(reason: JourneyEvent.R_FORCED)
        masterController?.api.bgEvents.postEvent("JourneyStopPosting", data: evd)
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func startLogout(menuItem : MenuItem) {
        let evd = JourneyEventData(reason: JourneyEvent.R_FORCED)
        masterController?.api.bgEvents.postEvent("JourneyStopPosting", data: evd)
        navigationController?.popToRootViewControllerAnimated(true)
        if (masterController?.api.isLoggedIn() != nil) {
            let evd1 = LoginEventData(loginManager: masterController!.api.loginManager!)
            masterController?.api.bgEvents.postEvent("Logout", data: evd1)
            Toast(title: "Logout", message: "Logging out", duration: 3).show()
        } else {
            Toast(title: "Logout", message: "Not logged in", duration: 3).show()
        }
    }
    
    func busmeTransitMenu() -> MenuItem {
        let submenu : [MenuItem] = [
            MenuItem(title: "Select", action: "busme", target: self),
            MenuItem(title: "Save As Default", action: "busme", target: self),
            MenuItem(title: "Remove As Default", action: "busme", target: self),
            MenuItem(title: "Store", action: "busme", target: self),
            MenuItem(title: "Reload", action: "busme", target: self)
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
        } else if title == "Store" {
            store(menuItem)
        } else if title == "Reload" {
            reloadStore(menuItem)
        }
    }
    
    func reloadStore(menuItem : MenuItem) {
        mainController!.masterController?.reloadStores();
    }
    
    func store(menuItem : MenuItem) {
        mainController!.masterController?.storeMaster()
    }
    
    func busmeSelect(menuItem : MenuItem) {
        mainController!.api.bgEvents.postEvent("Main:init", data: MainEventData(forceDiscover: true))
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
            masterController!.api.uiEvents.postEvent("StopTimers", data: MainEventData())
            masterController!.api.bgEvents.postEvent("Master:reload", data: MasterEventData())
            Toast(title: "Reload All", message: "", duration: 1).show()
        } else if title == "Reset Seen Markers" {
            masterController!.api.bgEvents.postEvent("Master:resetSeenMarkers", data: MasterEventData())
            Toast(title: "Reset Seen Markers", message: "The markers you have ingored will now reappear if appropriate and not expired.", duration: 2).show()
        } else if title == "Reset Seen Messages"{
            masterController!.api.bgEvents.postEvent("Master:resetSeenMessages", data: MasterEventData())
            Toast(title: "Reset Seen Markers", message: "The messages you have marked as seen will now reappear if and when scheduled and not expired.", duration: 2).show()
        }
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}
