//
//  MedicineTableViewController.swift
//  iMedicine
//
//  Created by Иван Базаров on 24.04.17.
//  Copyright © 2017 Иван Базаров. All rights reserved.
//

import UIKit
import CoreData
import SQLite
import CoreLocation
import Kanna
import Alamofire


class MedicineTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchResultsUpdating, CLLocationManagerDelegate {
    
    
    var medicine_test: [Medicine2] = []
    var searchResult: [Medicine2] = []
    var fetchResultController: NSFetchedResultsController!
    var searchController: UISearchController!
    var locationManager = CLLocationManager()
    var nameMatch:Range<String.Index>?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        StructOperation.globalVariable.alert_appeared = false
        
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        

        
        medicine_test = MedicineDB.instance.getMedicine()
    
        
        searchController = UISearchController(searchResultsController: nil)
        tableView.tableHeaderView = searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        searchController.searchBar.placeholder = "Поиск лекарства..."
        searchController.searchBar.tintColor = UIColor.whiteColor()
        searchController.searchBar.barTintColor = UIColor(red: 5.0/255.0, green: 140.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        tableView.backgroundColor = UIColor(red: 50.0/255.0, green: 175.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active {
            return searchResult.count
        }else {
            
            return medicine_test.count
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! CustomTableViewCell
        
        cell.backgroundColor = UIColor(red: 50.0/255.0, green: 175.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        cell.NameExpLabel.textColor = UIColor.whiteColor()
        
        let medicine2 = (searchController.active) ? searchResult[indexPath.row] : medicine_test[indexPath.row]
        
        cell.NameExpLabel?.text = medicine2.InputName
        return cell
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if searchController.active {
            return false
        }else {
            return true
        }
    }
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showDetail" {
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destinationViewController as! DetailViewController
                destinationController.medicineDetail = (searchController.active) ? searchResult[indexPath.row] :medicine_test[indexPath.row]
            
                }
            
        searchController.active = false
        }
        
    }
    
    @IBAction func unwindToMedicine(segue: UIStoryboardSegue) {
        
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            filtercontent(searchText)
            tableView.reloadData()
        }
    }
    
    
    func filtercontent(searchText: String){
        searchResult = medicine_test.filter({ (medicine_test: Medicine2) -> Bool in
        
        
        self.nameMatch = medicine_test.InputName.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            
            return nameMatch != nil
        })
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways{
            locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.first != nil {
            let location = locations.first
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("error:: (error)")
    }
    
            
}
