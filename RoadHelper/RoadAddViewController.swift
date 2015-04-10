//
//  RouteAddViewController.swift
//  RoadHelper
//
//  Created by Eugene on 10/04/15.
//  Copyright (c) 2015 Eugene Antropov. All rights reserved.
//

import UIKit
import MagicalRecord

class RoadAddViewController: UIViewController {
    var road:Road?
    
    @IBOutlet weak var nameTextField:UITextField!
    @IBOutlet weak var countTextField:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension RoadAddViewController{
    @IBAction func saveButtonPressed(){
        MagicalRecord.saveWithBlock({[weak self] (context) -> Void in
            if let sself = self{
                let road = Road.MR_createEntityInContext(context)
                road.name = sself.nameTextField.text
                road.totalKLM = NSNumber(unsignedLong: UInt(sself.countTextField.text.toInt() ?? 0))
            }
        }, completion: {[weak self] (success, error) -> Void in
            if success == true {
                self?.navigationController?.popViewControllerAnimated(true)
            }
        })
        
    }
}