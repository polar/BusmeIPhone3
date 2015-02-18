//
//  DiscoverMenu.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 2/4/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit


class DiscoverMenu : MenuScreen, MenuDelegate {
    weak var mainController : MainController?
    weak var discoverController : DiscoverController?
    weak var discoverScreen : DiscoverScreen?
    
    func initWithDiscoverScreen(discoverScreen : DiscoverScreen, mainController : MainController) -> DiscoverMenu {
        self.discoverScreen = discoverScreen
        self.discoverController = mainController.discoverController
        self.mainController = mainController
        initWithMenuData("Menu", menu_data: initMenuData())
        return self
    }
    
    func initMenuData() -> [MenuItem]{
        return [
            operationMenu(),
            aboutMenu()
        ]
    }
    
    func operationMenu() -> MenuItem {
        let submenu : [MenuItem] = [
            MenuItem(title: "Normal", action: "operation", target: self, checked: mainController!.api.operationMode == OPM_NORMAL),
            MenuItem(title: "Test", action: "operation", target: self, checked: mainController!.api.operationMode == OPM_TEST),
        ]
        return MenuItem(title: "Operation Mode", submenu: submenu)
    }
    
    func aboutMenu() -> MenuItem {
        return MenuItem(title: "About Busme", action: "about", target: self)
    }
    
    
    func menuItemSelected(menuItem: MenuItem) -> Bool {
        let action = menuItem.action
        if action == "operation" {
            operation(menuItem)
        } else if action == "about" {
            about(menuItem)
        } else if action == "help" {
            help(menuItem)
        }
        return true
    }

    private var initInProgress = false
    func operation(menuItem : MenuItem) {
        if initInProgress {
            return
        }
        
        if (menuItem.title == "Normal") {
            if (mainController!.api.operationMode == OPM_NORMAL) {
                Toast(title: "Normal Mode", message: "Already in Normal Operation Mode", duration: 2).show()
                navigationController?.popToRootViewControllerAnimated(true)
            } else {
                mainController!.api.switchMode(OPM_NORMAL)
                initInProgress = true
                let data = MainEventData()
                data.forceDiscover = true
                data.dialog = UIAlertView(title: "Operation Mode", message: "Switching to Normal Operation Mode", delegate: nil, cancelButtonTitle: "OK")
                data.dialog?.show()
                mainController!.api.bgEvents.postEvent("Main:init", data: data)            }
        } else if (menuItem.title == "Test") {
            if (mainController!.api.operationMode == OPM_TEST) {
                Toast(title: "Normal Mode", message: "Already in Test Operation Mode", duration: 2).show()
                navigationController?.popToRootViewControllerAnimated(true)
            } else {
                mainController!.api.switchMode(OPM_TEST)
                initInProgress = true
                let data = MainEventData()
                data.forceDiscover = true
                data.dialog = UIAlertView(title: "Operation Mode", message: "Switching to TEST Operation Mode", delegate: nil, cancelButtonTitle: "OK")
                data.dialog?.show()
                mainController!.api.bgEvents.postEvent("Main:init", data: data)
            }
        } else {
            navigationController?.popToRootViewControllerAnimated(true)
        }
        
    }
    
    func about(menuItem: MenuItem) {
        AboutDialog().show()
    }
    
    func help(menuItem: MenuItem) {
        
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("Dealloc") }
    }
}