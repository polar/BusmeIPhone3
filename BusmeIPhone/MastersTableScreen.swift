//
//  MastersTableScreen.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/14/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

public class MastersTableScreen : UITableViewController, UITableViewDelegate, UISearchDisplayDelegate {
    weak var discoverController : DiscoverController?
    
    public var masters : [Master] = [Master]()

    public init(discoverController :DiscoverController) {
        self.discoverController = discoverController
        self.masters = discoverController.getMasters()
        super.init()
        makeSearchable()
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var eventData : DiscoverEventData?
    
    public func reloadTableView() {
        let ms = discoverController?.getMasters()
        if ms != nil {
            self.masters = ms!
            self.filteredMasters = [Master]()
        }
        tableView.reloadData()
    }
    // MARK: TableView
    
    override public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.filteredMasters.count
        } else {
            return self.masters.count
        }
    }
    
    override public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //ask for a reusable cell from the tableview, the tableview will create a new one if it doesn't have any
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell
        
        // Get the corresponding candy from our candies array
        var master : Master
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            master = self.filteredMasters[indexPath.row]
        } else {
            master = self.masters[indexPath.row]
        }
        
        // Configure the cell
        cell.textLabel!.text = master.name
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell
    }
    
    override public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        var master : Master!
        
        if tableView == self.searchDisplayController?.searchResultsTableView {
            master = filteredMasters[indexPath.row]
        } else {
            master = masters[indexPath.row]
        }
        
        doMasterInit(master)
    }
    
    func searchDialog(title : String, message : String) -> UIAlertView {
        let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: nil)
        alertView.show()
        return alertView
    }
    
    func doMasterInit(master : Master) {
        self.navigationController?.popViewControllerAnimated(true)
        let eventData = MainEventData()
        eventData.master = master
        eventData.dialog = searchDialog("Welcome", message: master.name!)
        discoverController!.api.bgEvents.postEvent("Main:Master:init", data: eventData)
    }
    
    // Searchable
    
    var filteredMasters = [Master]()
    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        self.filteredMasters = self.masters.filter({( master: Master) -> Bool in
            let stringMatch = master.name!.rangeOfString(searchText)
            return (stringMatch != nil)
        })
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
    
    private var tableSearchController : UISearchDisplayController!
    
    func makeSearchable() {
        self.tableSearchController = UISearchDisplayController(searchBar: createSearchBar(), contentsController: self)
        
    }
    
    func createSearchBar() -> UISearchBar {
        let searchBar = UISearchBar(frame: CGRect(x: 0,y: 0,width: UIScreen.mainScreen().bounds.size.width, height: 40))
        searchBar.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        return searchBar
    }
}
