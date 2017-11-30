//
//  MedicineDatabase.swift
//  iMedicine
//
//  Created by Иван Базаров on 21.06.17.
//  Copyright © 2017 Иван Базаров. All rights reserved.
//

import Foundation
import SQLite

class MedicineDB {
    
    static let instance = MedicineDB()
    private let db:Connection?
    private let MedicineTB = Table("Medicine")
    private let consist = Expression<String>("Consist")
    private let inputname = Expression<String>("InputName")
    private let outputname = Expression<String>("OutPutName")
    private let default_price = Expression<String>("Default_Prices")
    private let description = Expression<String>("Description")
    private let spainAnalogue = Expression<String>("SpainAnalogue")
    private let input_price_name = Expression<String>("Input_Price_Name")
    private let output_price_name = Expression<String>("Output_Price_Name")
    
    private init() {
        
        let path = NSBundle.mainBundle().pathForResource("MedDBNew", ofType: "db")
        
        do {
            db = try Connection(path!)
        } catch {
            db = nil
            print ("Unable to connect to db")
        }
       
    }

    func getMedicine() -> [Medicine2] {
        var MedicineTB = [Medicine2]()
        
        
        do {
            for med in try db!.prepare(self.MedicineTB) {
                
                MedicineTB.append(Medicine2(
                    InputName: med[inputname],
                    OutPutName: med[outputname],
                    Consist: med[consist],
                    Description: med[description],
                    Price: med[default_price],
                    SpainAnalogue: med[spainAnalogue],
                    Input_Name_Price: med[input_price_name],
                    Output_Name_Price: med[output_price_name]))
               
            }
        } catch {
            print("Select failed")
        }
        return MedicineTB
    }
    
}