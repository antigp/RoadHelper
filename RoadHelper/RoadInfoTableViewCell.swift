//
//  RoadInfoTableViewCell.swift
//  RoadHelper
//
//  Created by Eugene on 10/04/15.
//  Copyright (c) 2015 Eugene Antropov. All rights reserved.
//

import UIKit

class RoadInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var routeKilometerLabel:UILabel!
    @IBOutlet weak var totalInfo:UILabel!
    @IBOutlet weak var infoWithGeoRect:UILabel!
    @IBOutlet weak var infoWithGeoPoint:UILabel!
    @IBOutlet weak var infoWithPhoto:UILabel!
    @IBOutlet weak var firstInfoName:UILabel!
    @IBOutlet weak var firstInfoRectDistance:UILabel!
    @IBOutlet weak var firstInfoPointDistance:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
