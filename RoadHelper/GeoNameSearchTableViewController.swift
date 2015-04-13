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

class GeoNameSearchTableViewController: UITableViewController,UISearchControllerDelegate {
    @IBOutlet weak var searchBarView:UISearchBar!
    
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
        
        
//        searchArray |> next(next:{[weak self] (object) in
//            self?.searchDisplayController?.searchResultsTableView.reloadData()
//            return
//        })
        
        self.searchDisplayController?.searchResultsTableView.registerClass(GeoSearchResultTableViewCell.self, forCellReuseIdentifier: "GeoSearchResultTableViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return searchArray.value.count
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
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        return UITableViewCell()
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
