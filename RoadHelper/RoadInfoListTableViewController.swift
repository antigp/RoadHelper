//
//  RoadInfoListTableViewController.swift
//  RoadHelper
//
//  Created by Eugene on 14/04/15.
//  Copyright (c) 2015 Eugene Antropov. All rights reserved.
//

import UIKit
import MagicalRecord
import ReactiveCocoa

class RoadInfoListTableViewController: UITableViewController,NSFetchedResultsControllerDelegate {
    var klm:Kilometr?{
        didSet{
            if let klm = self.klm{
                let predicate = NSPredicate(format: "klm = %@", argumentArray: [klm])
                self.fetchedController = Info.MR_fetchAllSortedBy("sort", ascending: true, withPredicate: predicate, groupBy: nil, delegate: self)
                self.tableView.reloadData()
            }
        }
    }
    
    var fetchedController:NSFetchedResultsController?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem()
        navigationItem.leftItemsSupplementBackButton = true
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (fetchedController?.sections?[0] as? NSFetchedResultsSectionInfo)?.numberOfObjects ?? 0
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let info = fetchedController?.objectAtIndexPath(indexPath) as? Info {
            let cell = tableView.dequeueReusableCellWithIdentifier("RoadInfoListTableViewCell", forIndexPath: indexPath) as! RoadInfoListTableViewCell
            cell.infoName.text = info.name
            cell.infoDescr.text = info.descr
            let cellReuseSignal = cell.rac_prepareForReuseSignal.toSignalProducer()
                                    |> map{ object -> () in
                                        return
                                    }
                                    |> catch { _ in SignalProducer<(), NoError>.empty }
            LocationManager.instance().lastLocation.producer
                |> map({ object -> String in
                    return "Far"
                })
                |> takeUntil(cellReuseSignal)
                |> start(next:{ (object:String) in
                    cell.infoBoxDest.text = object
                })
            
            return cell
        }
        else{
            return UITableViewCell()
        }
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


    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
