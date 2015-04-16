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
            reloadMenu(),
            helpMenu()]
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
        } else if action == "help" {
            help(menuItem)
        }
        return true
    }
    
    func helpMenu() -> MenuItem {
        var submenu : [MenuItem] = [
            MenuItem(title: "Iconography", action: "help", target:self),
            MenuItem(title: "Help", action: "help", target:self),
            MenuItem(title: "About Busme!", action: "help", target:self)
        ]
        return MenuItem(title: "Help", submenu: submenu)
    }
    
    func help(menuItem: MenuItem) {
        if menuItem.title == "Iconography" {
            let controller = IconographyScreen().initIt()
            menuItem.navigationController?.pushViewController(controller, animated: true)
        } else if menuItem.title == "Help" {
            let controller = WebScreen()
            let helpUrl = masterController?.api.getHelpUrl()
            if helpUrl != nil {
                controller.openUrl(helpUrl!)
                menuItem.navigationController?.pushViewController(controller, animated: true)
            } else {
                menuItem.navigationController?.popToRootViewControllerAnimated(true)
            }
        } else if menuItem.title == "About Busme!" {
            menuItem.navigationController?.popToRootViewControllerAnimated(true)
            
            let msg = "Busme! iPhone Version \(APP_VERSION)\n(C) Copyright 2015, Adiron, LLC. All rights reserved."
            Toast(title: "About Busme!", message: msg, duration: 10).show()
        }
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
            UIAlertView(title: "Already Logged In", message: "You are already logged in. Please log out before trying to create a new user.", delegate: nil, cancelButtonTitle: "OK").show()
        } else {
            register(menuItem)
        }
    }
    
    func startLogin(menuItem : MenuItem) {
        if !masterController!.api.isLoggedIn() {
            login(menuItem)
        } else {
            let login = masterController!.api.loginCredentials!
            Toast(title: "Already Logged In", message: "You are already logged in.", duration : 5).show()
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
        let master = masterController!.master
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
        Toast(title: "Forget Me", message: "Your Busme! identity and credentials have been removed from the device for \(master.name!).", duration: 5).show()
    }
    
    func startReporting(menuItem : MenuItem) {
        // TODO
        if true { // masterController!.locationController.getLastKnownLocation() != nil
            if !masterController!.api.isLoggedIn() {
                login(menuItem)
            } else {
                if (menuItem.title == "Driver" && !masterController!.api.loginCredentials!.hasRole("driver")) {
                    Toast(title: "Not Authorized", message: "You are not authorized to report as a driver.", duration: 5).show()
                } else {
                    showSelections(menuItem)
                }
            }
        } else {
            Toast(title: "Need GPS", message: "We have not yet gotten GPS locations from your device.", duration: 5).show()
        }
    }
    
    func showSelections(menuItem : MenuItem) {
        if (!masterController!.journeyVisibilityController.hasCurrentLocation()) {
            Toast(title: "No Location", message: "We do not have a GPS location for your device. Please try later.", duration: 5).show()
            menuItem.navigationController?.popToRootViewControllerAnimated(true)
        } else {
            let role = menuItem.title == "Driver" ? "driver" : "passenger"
            var jds = masterController!.journeyVisibilityController.getJourneysAtCurrentLocation()
            if jds.count > 0 {
                var viewController = JourneyPostingSelectionView(api: masterController!.api, role: role, journeyDisplays: jds)
                menuItem.navigationController?.pushViewController(viewController, animated: true)
            } else {
                Toast(title: "No Selections", message: "There are no active journeys within your location.", duration: 5).show()
                menuItem.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    func stopReporting(menuItem : MenuItem) {
        if masterController!.journeyLocationPoster.isPosting() {
            let evd = JourneyEventData(reason: JourneyEvent.R_FORCED)
            masterController?.api.bgEvents.postEvent("JourneyStopPosting", data: evd)
        } else {
            Toast(title: "Not Reporting", message: "You were not reporting your location.", duration: 5).show()
        }
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func startLogout(menuItem : MenuItem) {
        let evd = JourneyEventData(reason: JourneyEvent.R_FORCED)
        masterController?.api.bgEvents.postEvent("JourneyStopPosting", data: evd)
        navigationController?.popToRootViewControllerAnimated(true)
        if (masterController?.api.isLoggedIn() != nil) {
            let evd1 = LoginEventData(loginManager: masterController!.api.loginManager!)
            masterController?.api.bgEvents.postEvent("Logout", data: evd1)
            Toast(title: "Logout", message: "You have been logged out.", duration: 3).show()
        } else {
            Toast(title: "Logout", message: "You are not currently logged in", duration: 3).show()
        }
    }
    
    func busmeTransitMenu() -> MenuItem {
        let master = masterController!.master
        let defaultMaster = mainController?.configurator.getDefaultMaster()
        var submenu : [MenuItem] = [
            MenuItem(title: "Select", action: "busme", target: self),
            MenuItem(title: "Set \(master.name!) as your default.", action: "busme", target: self),
        ]
        if defaultMaster != nil {
            submenu.append(
                MenuItem(title: "Unset \(defaultMaster!.name!) as your default.", action: "busme", target: self)
            )
        }
        if BLog.DEBUG {
            submenu.extend([
                MenuItem(title: "Store", action: "busme", target: self),
                MenuItem(title: "Reload", action: "busme", target: self)
            ])
        }
        return MenuItem(title: "Busme Transit Systems", submenu: submenu)
    }
    
    func busme(menuItem : MenuItem) {
        let title = menuItem.title
        
        // You have got to be fucking kidding me. Figuring out whether a string starts with another string. Geez.
        if title.rangeOfString("Select") != nil && title.rangeOfString("Select")!.startIndex == title.startIndex {
            busmeSelect(menuItem)
        } else if title.rangeOfString("Set") != nil && title.rangeOfString("Set")!.startIndex == title.startIndex {
            busmeSaveAsDefault(menuItem)
        } else if title.rangeOfString("Unset") != nil && title.rangeOfString("Unset")!.startIndex == title.startIndex {
            busmeRemoveAsDefault(menuItem)
        } else if title == "Store" {
            store(menuItem)
        } else if title == "Reload" {
            reloadStore(menuItem)
        }
    }
    
    func reloadStore(menuItem : MenuItem) {
        mainController!.masterController?.reloadStores()
        Toast(title: "Master reload", message: "\(masterController?.master.name!) is reloaded", duration: 5).show()
        menuItem.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func store(menuItem : MenuItem) {
        mainController!.masterController?.storeMaster()
        Toast(title: "Master reload", message: "\(masterController?.master.name!) is stored", duration: 5).show()
        menuItem.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func busmeSelect(menuItem : MenuItem) {
        mainController!.api.bgEvents.postEvent("Main:init", data: MainEventData(forceDiscover: true))
    }
    
    func busmeSaveAsDefault(menuItem : MenuItem) {
        // TODO Possible Error
        let master = masterController!.master
        mainController!.configurator.saveAsDefaultMaster(master)
        Toast(title: "Default Set", message: "\(master.name!) is now your default Busme Transit Site", duration: 5).show()
        menuItem.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func busmeRemoveAsDefault(menuItem : MenuItem) {
        let master = masterController!.master
        mainController!.configurator.removeAsDefault(master)
        Toast(title: "Default Unset", message: "\(master.name!) is no longer your default Busme Transit Site. You will be asked to select one next time.", duration: 5).show()
        menuItem.navigationController?.popToRootViewControllerAnimated(true)
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
            Toast(title : "Nearby Routes", message : nearBy == 0 ? "Now showing all routes." : "Now showing only routes within \(Int(nearBy)) feet.", duration: 5).show()
        }
        menuItem.navigationController?.popToRootViewControllerAnimated(true)
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
            Toast(title : "Active Buses", message : active ? "Now showing only active buses and routes." : "Now showing all routes.", duration: 5).show()
        }
        menuItem.navigationController?.popToRootViewControllerAnimated(true)
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
            Toast(title: "Reload All", message: "", duration: 5).show()
        } else if title == "Reset Seen Markers" {
            masterController!.api.bgEvents.postEvent("Master:resetSeenMarkers", data: MasterEventData())
            Toast(title: "Reset Seen Markers", message: "The markers you have ingored will now reappear if appropriate and not expired.", duration: 5).show()
        } else if title == "Reset Seen Messages"{
            masterController!.api.bgEvents.postEvent("Master:resetSeenMessages", data: MasterEventData())
            Toast(title: "Reset Seen Markers", message: "The messages you have marked as seen will now reappear if and when they are scheduled and not expired.", duration: 5).show()
        }
        menuItem.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }
}
