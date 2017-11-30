//
//  DetailViewController.swift
//  iMedicine
//
//  Created by Иван Базаров on 24.04.17.
//  Copyright © 2017 Иван Базаров. All rights reserved.
//

import UIKit
import Kanna
import Alamofire

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    var medicineDetail: Medicine2!
    var selectedCountry = ""
    var input_price_name = ""
    var output_price_name = ""
    var useDefault_price = true
    var value_label_text = ""
    var activityIndicatorView: ActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (StructOperation.globalVariable.Country == "") {
            
            StructOperation.globalVariable.Country = "Россия"
        }

        tableView.backgroundColor = UIColor(red: 50.0/255.0, green: 175.0/255.0, blue: 240.0/255.0, alpha: 1.0)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.tintColor = UIColor.whiteColor()
        title = medicineDetail.InputName
        tableView.estimatedRowHeight = 36.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (StructOperation.globalVariable.Country == "Россия") {
            return 4
        } else {
            return 3
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath:  indexPath) as! MedicineCustomTableViewCell
        
        cell.fieldLabel.tintColor = UIColor.whiteColor()
        cell.valueLabel.tintColor = UIColor.whiteColor()
        
        if (StructOperation.globalVariable.Country == "Россия") {
        switch indexPath.row {
        case 0:
            cell.fieldLabel.text = "Выгодная замена"
            cell.valueLabel.text = medicineDetail.OutPutName
        case 1:
            cell.fieldLabel.text = "Сравнение цен"
            cell.valueLabel.text = self.medicineDetail.Default_Price
            
            Price_Request(medicineDetail.Input_Name_Price, med_name_output: medicineDetail.Output_Name_Price) {(arr1) -> Void in
                
                self.input_price_name = ": " + StructOperation.globalVariable.input_price + " руб. \n"
                self.output_price_name = ": " + StructOperation.globalVariable.output_price + " руб."
                self.value_label_text = self.medicineDetail.InputName + self.input_price_name  + self.medicineDetail.OutPutName + self.output_price_name
                print ("!",StructOperation.globalVariable.input_price,"!")
                print ("!",StructOperation.globalVariable.output_price,"!")
                self.tableView.beginUpdates()
                cell.valueLabel.text = self.value_label_text
                self.tableView.endUpdates()
                
                self.activityIndicatorView.stopAnimating()
                
            }
            
        case 2:
            cell.fieldLabel.text = "Действующее вещество"
            cell.valueLabel.text = medicineDetail.Consist
        case 3:
            cell.fieldLabel.text = "Показания к применению"
            cell.valueLabel.text = medicineDetail.Description
        
        default:
            cell.fieldLabel.text = ""
            cell.valueLabel.text = ""
        
        }
        } else {
            switch indexPath.row {
            case 0:
                cell.fieldLabel.text = "Аналоги"
                cell.valueLabel.text = medicineDetail.SpainAnalogue
            case 1:
                cell.fieldLabel.text = "Действующее вещество"
                cell.valueLabel.text = medicineDetail.Consist
            case 2:
                cell.fieldLabel.text = "Показания к применению"
                cell.valueLabel.text = medicineDetail.Description
                
            default:
                cell.fieldLabel.text = ""
                cell.valueLabel.text = ""
                
            }
        }
        
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    
    
    func  Price_Request(med_name_input: String, med_name_output:String, completion:(XPathObject) -> Void)  {
        
        self.activityIndicatorView = ActivityIndicatorView(title: "Обновление цен", center: self.view.center)
        self.view.addSubview(self.activityIndicatorView.getViewActivityIndicator())
        self.activityIndicatorView.startAnimating()
        
        Alamofire.request(.GET, "https://health.mail.ru/drug/\(med_name_input)/").responseString{ response in
            
            switch response.result {
            case .Success:
                if let html = response.result.value {
                    if let doc = HTML(html: html, encoding: NSUTF8StringEncoding) {
                       let arr = doc.css("span[class^='price__number']")
                        
                        if arr.first?.text != nil {
                            StructOperation.globalVariable.input_price = (arr.first?.text)!
                        } else {
                            print (" цена не найдена 1")
                        }
                    }
                }
            case .Failure:
                
                self.activityIndicatorView.stopAnimating()
                if (StructOperation.globalVariable.alert_appeared == false) {
                    
                    StructOperation.globalVariable.alert_appeared = true
                
                let alertMessage = UIAlertController(title: "Не удалось обновить цены", message: "Проверьте подключение к интернету", preferredStyle: .Alert)
                alertMessage.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                self.presentViewController(alertMessage, animated: true, completion: nil)
                    
                }
            }
            
            Alamofire.request(.GET, "https://health.mail.ru/drug/\(med_name_output)/").responseString{ response in
                
                switch response.result {
                case .Success:
                    if let html = response.result.value {
                        if let doc = HTML(html: html, encoding: NSUTF8StringEncoding) {
                            let arr = doc.css("span[class^='price__number']")
                            
                            if arr.first?.text != nil {
                                StructOperation.globalVariable.output_price = (arr.first?.text)!
                            } else {
                                //print (" цена не найдена 1")
                            }
                            completion(arr)
                            
                        }
                    }
                case .Failure:
                    break
                    
                }
            }
        }
    }
}


