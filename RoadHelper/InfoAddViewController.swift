//
//  InfoAddViewController.swift
//  RoadHelper
//
//  Created by Eugene on 13/04/15.
//  Copyright (c) 2015 Eugene Antropov. All rights reserved.
//

import UIKit
import ReactiveCocoa
import CoreLocation
import MagicalRecord

class InfoAddViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate {
    var road:Road?
    var name = MutableProperty("")
    var boundingBox = MutableProperty(Optional<(CLLocationCoordinate2D,CLLocationCoordinate2D)>.None)
    var geoPoint = MutableProperty(Optional<CLLocationCoordinate2D>.None)
    var image = MutableProperty(Optional<UIImage>.None)
    
    @IBOutlet weak var nameButton:UIButton!
    @IBOutlet weak var showRectButton:UIButton!
    @IBOutlet weak var geoButton:UIButton!
    @IBOutlet weak var imageButton:UIButton!
    @IBOutlet weak var descrView:UITextView!
    @IBOutlet weak var klmPicker:UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let splitViewController = self.splitViewController as? RoadSplitViewController {
            road = splitViewController.road
        }
        
        name.producer
            |> map({ object -> String in
                return object != "" ? object ?? "Name" : "Name"
            })
            |> start(next:{[weak self] (object:String) in
                self?.nameButton.setTitle(object, forState: UIControlState.Normal)
            })
        
        geoPoint.producer
            |> map({ object -> String in
                if let coordinate = object {
                    return "\(coordinate.latitude), \(coordinate.longitude)"
                }
                else{
                    return "Geo Point"
                }
            })
            |> start(next:{[weak self] (object:String) in
                self?.geoButton.setTitle(object, forState: UIControlState.Normal)
            })
        
        image.producer
            |> start(next:{[weak self] object in
                self?.imageButton.setImage(object, forState: UIControlState.Normal)
            })
        
        boundingBox.producer
            |> start(next:{[weak self] object in
                if let box = object{
                    self?.showRectButton.hidden = false
                }
                else{
                    self?.showRectButton.hidden = true
                }
            })
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let geoNameSearch = segue.destinationViewController as? GeoNameSearchTableViewController{
            geoNameSearch.finishBlock = {[weak self] (object,box) in
                self?.name.value = object
                self?.boundingBox.value = box
                geoNameSearch.navigationController?.popViewControllerAnimated(true)
            }
        }
        if let showMapRectViewController = segue.destinationViewController as? ShowMapRectViewController{
            if let boundingBox = self.boundingBox.value {
                let maxLat = boundingBox.1.latitude
                let minLat = boundingBox.0.latitude
                let maxLon = boundingBox.1.longitude
                let minLon = boundingBox.0.longitude
                let spanLat = maxLat - minLat
                let spanLon = maxLon - minLon
                let rect = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: minLat+(spanLat/2), longitude: minLon+(spanLon/2)), span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon))
                showMapRectViewController.mapRect = rect
            }
        }
        if let addGeoViewController = segue.destinationViewController as? AddGeoViewController{
            if let boundingBox = self.boundingBox.value {
                let maxLat = boundingBox.1.latitude
                let minLat = boundingBox.0.latitude
                let maxLon = boundingBox.1.longitude
                let minLon = boundingBox.0.longitude
                let spanLat = maxLat - minLat
                let spanLon = maxLon - minLon
                let rect = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: minLat+(spanLat/2), longitude: minLon+(spanLon/2)), span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon))
                addGeoViewController.mapRect = rect
                addGeoViewController.finishBlock = {[weak self] coordinate in
                    self?.geoPoint.value = coordinate
                }
            }
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func doneButtonPressed(){
        MagicalRecord.saveWithBlock({[weak self] (context) -> Void in
            if let road = self?.road?.MR_inContext(context) {
                
                
                let info = Info.MR_createEntityInContext(context)
                let kilometer:Kilometr
                let predicate = NSPredicate(format: "klm = %@ AND road = %@", argumentArray: [NSNumber(long: self?.klmPicker.selectedRowInComponent(0) ?? 0), road])
                if let findedKilometer = Kilometr.MR_findFirstWithPredicate(predicate, inContext: context){
                    kilometer = findedKilometer
                }
                else{
                    kilometer = Kilometr.MR_createEntityInContext(context)
                    kilometer.road = road
                    kilometer.klm = NSNumber(long: self?.klmPicker.selectedRowInComponent(0) ?? 0)
                }
                let predicateSort = NSPredicate(format: "klm = %@", argumentArray: [kilometer])
                if let maxSortInfo = Info.MR_findFirstWithPredicate(predicateSort, sortedBy: "sort", ascending: false) {
                    info.sort = NSNumber(long: maxSortInfo.sort.longValue + 1)
                }
                info.klm = kilometer
                info.name = self?.name.value ?? "Name"
                info.descr = self?.descrView.text ?? ""
                if let boundingBox = self?.boundingBox.value {
                    info.minLat = boundingBox.0.latitude
                    info.minLon = boundingBox.0.longitude
                    info.maxLat = boundingBox.1.latitude
                    info.maxLon = boundingBox.1.longitude
                }
                if let geoPoint = self?.geoPoint.value {
                    info.lat = geoPoint.latitude
                    info.lon = geoPoint.longitude
                }
            }
        }, completion:{[weak self](success,error) in
            self?.navigationController?.popViewControllerAnimated(true)
        })
    }
    
}
