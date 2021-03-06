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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nameTextField.text = road?.name ?? ""
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
            if let road = self?.road?.MR_inContext(context), sself = self{
                road.name = sself.nameTextField.text
            }
            else{
                let road = Road.MR_createEntityInContext(context)
                road.name = self?.nameTextField.text ?? String()
            }
        }, completion: {[weak self] (success, error) -> Void in
            if success == true {
                self?.navigationController?.popViewControllerAnimated(true)
//                if let splitVC = self?.splitViewController {
//                    let barButtonItem = splitVC.displayModeButtonItem()
//                    UIApplication.sharedApplication().sendAction(Selector("toggleMasterVisible:"), to: splitVC, from: nil, forEvent: nil)
////                    splitVC.preferredDisplayMode = .PrimaryHidden
////                    splitVC.preferredDisplayMode = .Automatic
//////                    UIApplication.sharedApplication().sendAction(self!.navigationItem.leftBarButtonItem!.action, to: self!.navigationItem.leftBarButtonItem!.target, from: nil, forEvent: nil)
//                }
            }
        })
        
    }
}