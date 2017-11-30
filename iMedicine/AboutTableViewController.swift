//
//  AboutTableViewController.swift
//  iMedicine
//
//  Created by Иван Базаров on 22.06.17.
//  Copyright © 2017 Иван Базаров. All rights reserved.
//

import UIKit

class AboutTableViewController: UITableViewController {
    

    
    @IBOutlet var tableView_1: UITableView!
    var sectionTitle = ["Настройка страны", "Связаться с разработчиком", "О приложении"]
    var sectionContent = [["Россия","Испания"],["Написать письмо"],["Версия 2.21","В приложении используются следующие иконки: Icon made by Freepik, Madebyoliver from www.flaticon.com "]]
    var selectedCountry_arr = [true,false]
    var selectedCountry = "Россия"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView_1.estimatedRowHeight = 36.0
        tableView_1.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return sectionTitle.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch  section {
        case 0:
            return 2
        case 1:
            return 1
        case 2:
            return 2
        default:
            return 1
        }
        
    }

    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sectionTitle[section]
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell1", forIndexPath: indexPath) as! AboutCustomTableViewCell
        
        
        cell.AboutLabel.text = sectionContent[indexPath.section][indexPath.row]
        
        switch indexPath.section {
        case 0:
            cell.accessoryType = selectedCountry_arr[indexPath.row] ? .Checkmark : .None

        default:
            break
        }
        
        
        
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        switch  indexPath.section {
        case 0:
            if indexPath.row == 0 {
                self.selectedCountry_arr[1] = false
                self.selectedCountry = "Россия"
            } else {
                self.selectedCountry_arr[0] = false
                self.selectedCountry = "Испания"
                
            }
            self.selectedCountry_arr[indexPath.row] = true
            
        case 1:
            if indexPath.row == 0 {
                
                let alertMessage = UIAlertController(title: "Электронная почта", message: "ivan.ab001@yandex.ru", preferredStyle: .Alert)
                alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alertMessage, animated: true, completion: nil)
            }
        default:
            break
        }
        
        StructOperation.globalVariable.Country = self.selectedCountry
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        tableView.reloadData()
    }
}
