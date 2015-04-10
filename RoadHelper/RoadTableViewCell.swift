//
//  RoadTableViewCell.swift
//  RoadHelper
//
//  Created by Eugene on 10/04/15.
//  Copyright (c) 2015 Eugene Antropov. All rights reserved.
//

import UIKit

class RoadTableViewCell: UITableViewCell {
    var road:Road?{
        didSet{
            if let road = road{
                self.routeLabel.text = road.name
                self.kmLabel.text = "\(road.totalKLM) km."
            }
        }
    }
    @IBOutlet weak var routeLabel:UILabel!
    @IBOutlet weak var kmLabel:UILabel!
}
