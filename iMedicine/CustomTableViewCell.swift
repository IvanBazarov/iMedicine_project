//
//  CustomTableViewCell.swift
//  iMedicine
//
//  Created by Иван Базаров on 24.04.17.
//  Copyright © 2017 Иван Базаров. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var NameExpLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
