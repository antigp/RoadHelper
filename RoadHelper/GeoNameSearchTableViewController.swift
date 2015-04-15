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
        self.searchDisplayController?.searchResultsTableView.registerNib(UINib(nibName: "GeoSearchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "GeoSearchResultTableViewCell")
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
                        cell.nameLabel?.text = name
                    }
                    if let description = geoObject["description"] as? String {
                        cell.descrLabel?.text = description
                    }
                    if let  lowerCornerString = ((geoObject["boundedBy"] as? Dictionary<String,AnyObject>)?["Envelope"] as? Dictionary<String,AnyObject>)?["lowerCorner"] as? String,
                            upperCornerString = ((geoObject["boundedBy"] as? Dictionary<String,AnyObject>)?["Envelope"] as? Dictionary<String,AnyObject>)?["upperCorner"] as? String {
                        
                                let lowerCornerComponent = lowerCornerString.componentsSeparatedByString(" ")
                                let upperCornerComponent = upperCornerString.componentsSeparatedByString(" ")
                                let numberFormater = NSNumberFormatter()
                                numberFormater.decimalSeparator = "."
                                if let  lowerCornerLat =  numberFormater.numberFromString(lowerCornerComponent[1])?.doubleValue,
                                        lowerCornerLon =  numberFormater.numberFromString(lowerCornerComponent[0])?.doubleValue,
                                        upperCornerLat =  numberFormater.numberFromString(upperCornerComponent[1])?.doubleValue,
                                        upperCornerLon =  numberFormater.numberFromString(upperCornerComponent[0])?.doubleValue {
                                            
                                        let lowerCorner = CLLocationCoordinate2D(latitude: lowerCornerLat, longitude: lowerCornerLon)
                                        let upperCorner = CLLocationCoordinate2D(latitude: upperCornerLat, longitude: upperCornerLon)
                                        let cellReuseSignal = cell.rac_prepareForReuseSignal.toSignalProducer()
                                            |> map{ object -> () in
                                                return
                                            }
                                            |> catch { _ in SignalProducer<(), NoError>.empty }
                                        LocationManager.instance().lastLocation.producer
                                            |> map({ object -> String in
                                                if let point = object {
                                                    let maxLat = upperCorner.latitude
                                                    let minLat = lowerCorner.latitude
                                                    let maxLon = upperCorner.longitude
                                                    let minLon = lowerCorner.longitude
                                                    let spanLat = maxLat - minLat
                                                    let spanLon = maxLon - minLon
                                                    let rect = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: minLat+(spanLat/2), longitude: minLon+(spanLon/2)), span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon))
                                                    let distance = LocationManager.calculateDistanceBetwen(rect: rect, userPoint: point)
                                                    return "\(Int(distance))m"
                                                    
                                                }
                                                return ""
                                            })
                                            |> takeUntil(cellReuseSignal)
                                            |> start(next:{ (object:String) in
                                                cell.distanceLabel.text = object
                                            })
                                        cell.button.rac_signalForControlEvents(UIControlEvents.TouchUpInside).toSignalProducer()
                                            |> takeUntil(cellReuseSignal)
                                            |> start(next:{[weak self] object in
                                                let maxLat = upperCorner.latitude
                                                let minLat = lowerCorner.latitude
                                                let maxLon = upperCorner.longitude
                                                let minLon = lowerCorner.longitude
                                                let spanLat = maxLat - minLat
                                                let spanLon = maxLon - minLon
                                                let rect = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: minLat+(spanLat/2), longitude: minLon+(spanLon/2)), span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon))
                                                if let viewController = self?.storyboard?.instantiateViewControllerWithIdentifier("ShowMapRectViewController") as? ShowMapRectViewController{
                                                    viewController.mapRect = rect
                                                    self?.navigationController?.pushViewController(viewController, animated: true)
                                                }
                                            })
                                }
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
                                if let  lowerCornerLat =  numberFormater.numberFromString(lowerCornerComponent[1])?.doubleValue,
                                        lowerCornerLon =  numberFormater.numberFromString(lowerCornerComponent[0])?.doubleValue,
                                        upperCornerLat =  numberFormater.numberFromString(upperCornerComponent[1])?.doubleValue,
                                        upperCornerLon =  numberFormater.numberFromString(upperCornerComponent[0])?.doubleValue {
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
                let lastLocation:String
                if let lastLocationCoorndinate = LocationManager.instance().lastLocation.value {
                    lastLocation = "\(lastLocationCoorndinate.coordinate.longitude),\(lastLocationCoorndinate.coordinate.latitude)"
                }
                else{
                    lastLocation = ""
                }
                request(.GET, urlString, parameters: ["ll":lastLocation, "geocode": testString,"format":"json"]).responseJSON(completionHandler: { (request, response, object, error) -> Void in
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
