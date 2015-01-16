//
//  MastersTableScreen.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/14/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation
import UIKit

public class MastersTableScreen : UITableViewController, UITableViewDelegate,UISearchDisplayDelegate {
    weak var discoverController : DiscoverController?
    public var masters : [Master] = [Master]()

    public func setDiscoverController(discoverController :DiscoverController) {
        self.discoverController = discoverController
        self.masters = discoverController.getMasters()
        makeSearchable()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = searchBar
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
        var cell : UITableViewCell? = self.tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
        
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        }
        
        // Get the corresponding candy from our candies array
        var master : Master
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            master = self.filteredMasters[indexPath.row]
        } else {
            master = self.masters[indexPath.row]
        }
        
        // Configure the cell
        cell!.textLabel!.text = master.name
        cell!.accessoryType = UITableViewCellAccessoryType.None
        
        return cell!
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
        let eventData = MainEventData(master: master)
        discoverController!.api.uiEvents.postEvent("Main:Discover:return", data: eventData)
    }
    
    // Searchable
    
    var filteredMasters = [Master]()
    
    func filterContentForSearchText(searchText: String) {
        // Filter the array using the filter method
        self.filteredMasters = self.masters.filter({( master: Master) -> Bool in
            let stringMatch = master.name!.rangeOfString(searchText)
            return (stringMatch != nil)
        })
        let count = self.filteredMasters.count
        return
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        filterContentForSearchText(searchString)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        let scope = controller.searchBar.scopeButtonTitles as [String]
        filterContentForSearchText(controller.searchBar.text)
        return true
    }
    
    private var tableSearchController : UISearchDisplayController!
    private var searchBar : UISearchBar!
    
    func makeSearchable() {
        self.searchBar = createSearchBar()
        self.tableSearchController = UISearchDisplayController(searchBar: searchBar, contentsController: self)
        tableSearchController.delegate = self
        tableSearchController.searchResultsDataSource = self;
        tableSearchController.searchResultsDelegate = self;
    }
    
    func createSearchBar() -> UISearchBar {
        let searchBar = UISearchBar(frame: CGRect(x: 0,y: 0,width: UIScreen.mainScreen().bounds.size.width, height: 40))
        searchBar.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        return searchBar
    }
}
