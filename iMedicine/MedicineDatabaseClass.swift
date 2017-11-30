//
//  MedicineDatabase.swift
//  iMedicine
//
//  Created by Иван Базаров on 21.06.17.
//  Copyright © 2017 Иван Базаров. All rights reserved.
//

import Foundation


class Medicine2 {
    
    var InputName: String
    var OutPutName: String
    var Consist: String
    var Default_Price: String
    var Description: String
    var SpainAnalogue:String
    var Input_Name_Price: String
    var Output_Name_Price: String
    
    
    init() {
        
        InputName = ""
        OutPutName = ""
        Consist = ""
        Description = ""
        Default_Price = ""
        SpainAnalogue = ""
        Input_Name_Price = ""
        Output_Name_Price = ""
    }
    
    init(InputName: String, OutPutName: String, Consist: String, Description: String, Price: String, SpainAnalogue: String, Input_Name_Price: String, Output_Name_Price: String) {
        
        self.InputName = InputName
        self.OutPutName = OutPutName
        self.Consist = Consist
        self.Description = Description
        self.Default_Price = Price
        self.SpainAnalogue = SpainAnalogue
        self.Input_Name_Price = Input_Name_Price
        self.Output_Name_Price = Output_Name_Price
    }
}