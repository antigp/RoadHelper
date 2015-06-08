//
//  RoadTableViewController.swift
//  RoadHelper
//
//  Created by Eugene on 10/04/15.
//  Copyright (c) 2015 Eugene Antropov. All rights reserved.
//

import UIKit
import MagicalRecord
import ReactiveCocoa

class RoadTableViewController: UITableViewController, NSFetchedResultsControllerDelegate,UISplitViewControllerDelegate {
    var road:Road? {
        didSet{
            if let road = self.road{
                let predicate = NSPredicate(format: "klm.road = %@", argumentArray: [road])
                let fetchRequest = NSFetchRequest(entityName: "Info")
                fetchRequest.predicate = predicate
                let sortDescriptor1 = NSSortDescriptor(key: "klm.klm", ascending: true)
                let sortDescriptor2 = NSSortDescriptor(key: "sort", ascending: true)
                fetchRequest.sortDescriptors = [sortDescriptor1,sortDescriptor2]
                self.fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: NSManagedObjectContext.MR_defaultContext(), sectionNameKeyPath: "klm.klm", cacheName: nil)
                self.fetchedController?.delegate = self
                self.fetchedController?.performFetch(nil)
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
                return fetchedController?.sections?.count ?? 0
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
            let newIndexPath = NSIndexPath(forItem: 0, inSection: indexPath.item)
            if let roadInfo = fetchedController?.objectAtIndexPath(newIndexPath) as? Info {
                let cell = tableView.dequeueReusableCellWithIdentifier("RoadInfoTableViewCell", forIndexPath: indexPath) as! RoadInfoTableViewCell
                cell.routeKilometerLabel.text = "\(roadInfo.klm.klm) klm."
                cell.totalInfo.text = "\(roadInfo.klm.infos.count)"
                if let allInfosArray = roadInfo.klm.infos.allObjects as? [Info] {
                    cell.infoWithGeoRect.text = "\(allInfosArray.filter({$0.minLat != nil}).count)"
                    cell.infoWithGeoPoint.text = "\(allInfosArray.filter({$0.lat != nil}).count)"
                    cell.infoWithPhoto.text = "\(allInfosArray.filter({$0.voice != nil}).count)"
                }
                cell.firstInfoName.text = "\(roadInfo.name)"
                cell.firstInfoText.text = "\(roadInfo.descr)"
                let cellReuseSignal = cell.rac_prepareForReuseSignal.toSignalProducer()
                    |> map{ object -> () in
                        return
                    }
                    |> catch { _ in SignalProducer<(), NoError>.empty }
                LocationManager.instance().lastLocation.producer
                    |> map({ object -> String in
                        if let point = object {
                            if let  maxLat = roadInfo.maxLat?.doubleValue,
                                    minLat = roadInfo.minLat?.doubleValue,
                                    maxLon = roadInfo.maxLon?.doubleValue,
                                    minLon = roadInfo.minLon?.doubleValue
                                {
                                    let spanLat = maxLat - minLat
                                    let spanLon = maxLon - minLon
                                    let rect = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: minLat+(spanLat/2), longitude: minLon+(spanLon/2)), span: MKCoordinateSpan(latitudeDelta: spanLat, longitudeDelta: spanLon))
                                    let distance = LocationManager.calculateDistanceBetwen(rect: rect, userPoint: point)
                                    return "\(Int(distance))m"
                                }
                        }
                        return ""
                    })
                    |> takeUntil(cellReuseSignal)
                    |> start(next:{ (object:String) in
                        cell.firstInfoRectDistance.text = object
                    })
                LocationManager.instance().lastLocation.producer
                    |> map({ object -> String in
                        if let userPoint = object {
                            if let  lat = roadInfo.lat?.doubleValue,
                                    lon = roadInfo.lon?.doubleValue
                            {
                                let point = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                let distance = LocationManager.calculateDistanceBetwen(point: point, userPoint: userPoint)
                                return "\(Int(distance))m"
                            }
                        }
                        return ""
                    })
                    |> takeUntil(cellReuseSignal)
                    |> start(next:{ (object:String) in
                        cell.firstInfoPointDistance.text = object
                    })
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
    
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(indexPath.section){
        case 1:
            let newIndexPath = NSIndexPath(forItem: 0, inSection: indexPath.item)
            if let roadInfo = fetchedController?.objectAtIndexPath(newIndexPath) as? Info {
                if let infoListViewController = self.storyboard?.instantiateViewControllerWithIdentifier("RoadInfoListNavigationViewController") as? UINavigationController {
                    if let viewController = infoListViewController.viewControllers.first as? RoadInfoListTableViewController {
                        viewController.klm = roadInfo.klm
                        splitViewController?.showDetailViewController(infoListViewController, sender: nil)
                    }
                }
            }
        default:
            println()
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
