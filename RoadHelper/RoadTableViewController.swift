//
//  RoadTableViewController.swift
//  RoadHelper
//
//  Created by Eugene on 10/04/15.
//  Copyright (c) 2015 Eugene Antropov. All rights reserved.
//

import UIKit
import MagicalRecord

class RoadTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var road:Road? {
        didSet{
            if let road = self.road{
                let predicate = NSPredicate(format: "road = %@", argumentArray: [road])
                self.fetchedController = Kilometr.MR_fetchAllSortedBy("klm", ascending: true, withPredicate: predicate, groupBy: nil, delegate: self)
                self.tableView.reloadData()
            }
        }
    }
    var fetchedController:NSFetchedResultsController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let splitViewController = self.splitViewController as? RoadSplitViewController {
            road = splitViewController.road
        }
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
                return (fetchedController?.sections?[0] as? NSFetchedResultsSectionInfo)?.numberOfObjects ?? 0
            default:
                return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch(indexPath.section){
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("AboutRoadTableViewCell", forIndexPath: indexPath) as! AboutRoadTableViewCell
            cell.routeName.text = self.road?.name ?? "Road name"
            return cell
        case 1:
            let newIndexPath = NSIndexPath(forItem: indexPath.item, inSection: 0)
            if let roadInfo = fetchedController?.objectAtIndexPath(newIndexPath) as? Kilometr {
                let cell = tableView.dequeueReusableCellWithIdentifier("RoadInfoTableViewCell", forIndexPath: indexPath) as! RoadInfoTableViewCell
                cell.routeKilometerLabel.text = "\(roadInfo.klm) klm."
                return cell
            }
        default:
            assert(false, "Unknow cell")
        }
        assert(false, "Now cell to return")
        return UITableViewCell()
    }

    @IBAction func backButtonPressed(){
        self.splitViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addButtonPressed(){
        
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
