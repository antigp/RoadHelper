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
            }
        }
    }
    @IBOutlet weak var routeLabel:UILabel!
}
