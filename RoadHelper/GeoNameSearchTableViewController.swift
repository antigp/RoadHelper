//
//  GeoNameSearchTableViewController.swift
//  RoadHelper
//
//  Created by Eugene on 13/04/15.
//  Copyright (c) 2015 Eugene Antropov. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Alamofire
import CoreLocation

class GeoNameSearchTableViewController: UITableViewController,UISearchControllerDelegate {
    @IBOutlet weak var searchBarView:UISearchBar!
    var finishBlock:((String,(CLLocationCoordinate2D,CLLocationCoordinate2D)?)->Void)?
    
    var textString = MutableProperty("")
    var searchArray = MutableProperty(Array<Dictionary<String, AnyObject>>())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textString <~ searchBarView.rac_textSignal().toSignalProducer()
                        |> filter{$0 is String}
                        |> map{$0 as! String}
                        |> catch { _ in SignalProducer<String, NoError>.empty }
        
        
        searchArray <~ textString.producer
                        |> joinMap(JoinStrategy.Merge, { (object) in
                            return GeoNameSearchTableViewController.searchSignal(object)
                        })
        
        searchArray.producer
            |> start (next: {[weak self] value in
                self?.searchDisplayController?.searchResultsTableView.reloadData()
            })
        
        self.searchDisplayController?.searchResultsTableView.registerClass(GeoSearchResultTableViewCell.self, forCellReuseIdentifier: "GeoSearchResultTableViewCell")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        searchBarView.becomeFirstResponder()
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case 0:
            return 1
        case 1:
            return searchArray.value.count
        default:
            return 0
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section){
        case 0:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Without geo: '\(textString.value)'"
            return cell
        case 1:
            if searchArray.value.count > indexPath.row{
                let object = searchArray.value[indexPath.row]
                let cell = tableView.dequeueReusableCellWithIdentifier("GeoSearchResultTableViewCell", forIndexPath: indexPath) as! GeoSearchResultTableViewCell
                if let geoObject = object["GeoObject"] as? Dictionary<String, AnyObject>{
                    if let name = geoObject["name"] as? String {
                        cell.textLabel?.text = name
                    }
                    if let description = geoObject["description"] as? String {
                        cell.detailTextLabel?.text = description
                    }
                }
                // Configure the cell...
                
                return cell
            }
        default:
            return UITableViewCell()
        }
        return UITableViewCell()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.section){
        case 0:
            finishBlock?(textString.value, nil)
        case 1:
            if searchArray.value.count > indexPath.row{
                let object = searchArray.value[indexPath.row]
                if let geoObject = object["GeoObject"] as? Dictionary<String, AnyObject>{
                    if let name = geoObject["name"] as? String,
                           lowerCornerString = ((geoObject["boundedBy"] as? Dictionary<String,AnyObject>)?["Envelope"] as? Dictionary<String,AnyObject>)?["lowerCorner"] as? String,
                           upperCornerString = ((geoObject["boundedBy"] as? Dictionary<String,AnyObject>)?["Envelope"] as? Dictionary<String,AnyObject>)?["upperCorner"] as? String {
                                let lowerCornerComponent = lowerCornerString.componentsSeparatedByString(" ")
                                let upperCornerComponent = upperCornerString.componentsSeparatedByString(" ")
                                let numberFormater = NSNumberFormatter()
                                numberFormater.decimalSeparator = "."
                                if let  lowerCornerLat =  numberFormater.numberFromString(lowerCornerComponent[0])?.doubleValue,
                                        lowerCornerLon =  numberFormater.numberFromString(lowerCornerComponent[1])?.doubleValue,
                                        upperCornerLat =  numberFormater.numberFromString(upperCornerComponent[0])?.doubleValue,
                                        upperCornerLon =  numberFormater.numberFromString(upperCornerComponent[1])?.doubleValue {
                                            let lowerCorner = CLLocationCoordinate2D(latitude: lowerCornerLat, longitude: lowerCornerLon)
                                            let upperCorner = CLLocationCoordinate2D(latitude: upperCornerLat, longitude: upperCornerLon)
                                            finishBlock?(name, (lowerCorner,upperCorner))
                                            return
                                }
                            
                    }
                    finishBlock?(textString.value, nil)
                    return
                }
            }
        default:
            assert(false,"Unknow handler")
        }
    }

    class func searchSignal(testString:String) -> SignalProducer<Array<Dictionary<String,AnyObject>>, NoError>{
        let signal:SignalProducer<Array<Dictionary<String,AnyObject>>, NSError> = SignalProducer { observer, disposable in
            if let urlString = NSURL(string: "http://geocode-maps.yandex.ru/1.x/") {
                request(.GET, urlString, parameters: ["ll":"37.618920,55.756994", "geocode": testString,"format":"json"]).responseJSON(completionHandler: { (request, response, object, error) -> Void in
                    if let json = object as? Dictionary<String, AnyObject>{
                        if let members = (json["response"]?["GeoObjectCollection"] as? Dictionary<String, AnyObject>)?["featureMember"] as? Array<Dictionary<String, AnyObject>>{
                            sendNext(observer, members)
                        }
                    }
                    if let error = error{
                        sendError(observer,error)
                    }
                    sendCompleted(observer)
                })
            }
            else{
                sendCompleted(observer)
                sendError(observer, NSError(domain: "yandex.json", code: 500, userInfo: nil))
            }
        }
        return signal |> catch { _ in SignalProducer<Array<Dictionary<String,AnyObject>>, NoError>.empty }
    }
}
