//
//  RoadInfoViewController.swift
//  RoadHelper
//
//  Created by Eugene on 10/04/15.
//  Copyright (c) 2015 Eugene Antropov. All rights reserved.
//

import UIKit

class RoadInfoViewController: UIViewController {
    var road:Road?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let splitViewController = self.splitViewController as? RoadSplitViewController {
            road = splitViewController.road
        }
        //navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        //navigationItem.leftItemsSupplementBackButton = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
