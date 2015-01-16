//
//  MenuScreen.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/16/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

protocol MenuDelegate {
    func menuItemSelected(menu_item : MenuItem) -> Bool
}

class MenuItem {
    var title : String
    var action : String?
    var target : MenuDelegate?
    var checked : Bool?
    var submenu : [MenuItem]?
    init(title : String, action: String, target : MenuDelegate) {
        self.title = title
        self.action = action
        self.target = target
    }
    init(title : String, action: String, target : MenuDelegate, checked : Bool) {
        self.title = title
        self.action = action
        self.target = target
        self.checked = checked
    }
    init(title : String, submenu : [MenuItem]) {
        self.title = title
        self.submenu = submenu
    }
}

class MenuScreen : UITableViewController {
    var menu_data : [MenuItem] = [MenuItem]()

    func initWithMenuData(title : String, menu_data : [MenuItem]) -> MenuScreen {
        self.title = title
        self.menu_data = menu_data
        return self
    }
    
    override func viewDidLoad() {
        navigationController!.navigationItem.title = title
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menu_data.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        var cell : UITableViewCell? = self.tableView.dequeueReusableCellWithIdentifier("MenuItem") as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MenuITem")
        }
        
        let item = menu_data[indexPath.row]
        
        cell!.textLabel!.text = item.title
        if item.submenu != nil {
            cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        } else if (item.checked != nil && item.checked!) {
            cell!.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell!.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let menu_item = menu_data[indexPath.row]
        if menu_item.submenu != nil {
            let menuScreen = MenuScreen().initWithMenuData(menu_item.title, menu_data: menu_item.submenu!)
            navigationController?.pushViewController(menuScreen, animated: true)
        } else {
            navigationController?.popToRootViewControllerAnimated(true)
            menu_item.target?.menuItemSelected(menu_item)
        }
    }
}