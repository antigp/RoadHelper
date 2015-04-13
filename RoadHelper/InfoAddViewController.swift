//
//  InfoAddViewController.swift
//  RoadHelper
//
//  Created by Eugene on 13/04/15.
//  Copyright (c) 2015 Eugene Antropov. All rights reserved.
//

import UIKit

class InfoAddViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource {
    var road:Road?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let splitViewController = self.splitViewController as? RoadSplitViewController {
            road = splitViewController.road
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Int(road?.totalKLM ?? 0)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return "\(row) km."
    }

}
