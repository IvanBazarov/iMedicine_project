//
//  WarningTableViewController.swift
//  iMedicine
//
//  Created by Иван Базаров on 18.07.17.
//  Copyright © 2017 Иван Базаров. All rights reserved.
//

import UIKit

class WarningTableViewController: UITableViewController {
    
    
    
    @IBOutlet weak var customTableView: UITableView!
    
    var sectionTitle = ["Внимание"]
    var sectionContent = [["Перед применением необходимо проконсультироваться со специалистом!"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        customTableView.estimatedRowHeight = 36.0
        customTableView.rowHeight = UITableViewAutomaticDimension
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return sectionTitle.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sectionTitle[section]
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell2", forIndexPath: indexPath) as! WarningCustomTableViewCell
        
       cell.WarningLabel.text = sectionContent[indexPath.section][indexPath.row]
       return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
                
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
}




