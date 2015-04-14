//
//  RoadInfoListTableViewCell.swift
//  RoadHelper
//
//  Created by Eugene on 14/04/15.
//  Copyright (c) 2015 Eugene Antropov. All rights reserved.
//

import UIKit

class RoadInfoListTableViewCell: UITableViewCell {
    @IBOutlet weak var infoName:UILabel!
    @IBOutlet weak var infoDescr:UILabel!
    @IBOutlet weak var infoBoxDest:UILabel!
    @IBOutlet weak var infoPointDest:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
