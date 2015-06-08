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
import AVFoundation

class RoadInfoListTableViewController: UITableViewController,NSFetchedResultsControllerDelegate,AVAudioRecorderDelegate,AVAudioPlayerDelegate {
    var klm:Kilometr?{
        didSet{
            if let klm = self.klm{
                let predicate = NSPredicate(format: "klm = %@", argumentArray: [klm])
                self.fetchedController = Info.MR_fetchAllSortedBy("sort", ascending: true, withPredicate: predicate, groupBy: nil, delegate: self)
                self.tableView.reloadData()
            }
        }
    }
    lazy var recordFile:NSURL = {
        let documentPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        return NSURL(fileURLWithPath: documentPath.stringByAppendingString("/sound.caf"))!
        }()
    lazy var avAudioRecorder:AVAudioRecorder = {
        var error:NSError?
        let settings = [
            AVFormatIDKey: kAudioFormatAppleLossless,
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVNumberOfChannelsKey: 1,
            AVSampleRateKey : 44100.0] as [NSObject: AnyObject]
        let recorder = AVAudioRecorder(URL: self.recordFile, settings: settings, error: &error)
        recorder.delegate = self
        if let error = error{
            NSLog("%@",error)
        }
        return recorder
    }()
    
    var voicePlayer:AVAudioPlayer?
    var fetchedController:NSFetchedResultsController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        tableView.estimatedRowHeight = 65.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
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
                    if let point = object {
                        if let  maxLat = info.maxLat?.doubleValue,
                                minLat = info.minLat?.doubleValue,
                                maxLon = info.maxLon?.doubleValue,
                                minLon = info.minLon?.doubleValue
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
                    cell.infoBoxDest.text = object
                })
            LocationManager.instance().lastLocation.producer
                |> map({ object -> String in
                    if let userPoint = object {
                        if let  lat = info.lat?.doubleValue,
                                lon = info.lon?.doubleValue
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
                    cell.infoPointDest.text = object
                })
            
            return cell
        }
        else{
            return UITableViewCell()
        }
    }

    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
    }

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            MagicalRecord.saveWithBlock({[weak self] (context) -> Void in
                if let object = self?.fetchedController?.objectAtIndexPath(indexPath) as? Info{
                    object.MR_deleteEntityInContext(context)
                }
            })
        }  
    }



    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if let object = self.fetchedController?.objectAtIndexPath(sourceIndexPath) as? Info, allObjects = self.fetchedController?.fetchedObjects as? [Info] {
            var resultArray = allObjects
            resultArray.removeAtIndex(find(resultArray,object)!)
            resultArray.insert(object, atIndex: destinationIndexPath.row)
            var i:Int64 = 1
            
            let saveFunction:(sortIndex:Int64, object:Info)->Void =
                {(i,object) -> Void in
                    MagicalRecord.saveWithBlock {(context) -> Void in
                        let contextObject = object.MR_inContext(context)
                        contextObject.sort = NSNumber(longLong:i)
                    }
                }
            
            for object in resultArray{
                saveFunction(sortIndex: i, object: object)
                i++
            }
        }
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }

    @IBAction func startRecordVoice(sender:UIButton){
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryRecord, error: nil)
        avAudioRecorder.record()
        sender.backgroundColor = UIColor.redColor()
    }
    
    @IBAction func stopRecordVoice(sender:UIButton){
        avAudioRecorder.stop()
        AVAudioSession.sharedInstance().setCategory(nil, error: nil)
        sender.backgroundColor = UIColor.greenColor()
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        var error:NSError?
        if let avAudioPlayer = AVAudioPlayer(contentsOfURL: recordFile, error: &error){
            let duration = avAudioPlayer.duration
            MagicalRecord.saveWithBlock({[weak self] (context) -> Void in
                if let kilometer = self?.klm?.MR_inContext(context) {
                    let info = Info.MR_createEntityInContext(context)
                    info.klm = kilometer
                    let nsDateFormater = NSDateFormatter()
                    nsDateFormater.dateStyle = NSDateFormatterStyle.ShortStyle
                    nsDateFormater.timeStyle = NSDateFormatterStyle.MediumStyle
                    info.name = "\(nsDateFormater.stringFromDate(NSDate()))"
                    info.descr = "Voice record : \(duration) sec"
                    let predicateSort = NSPredicate(format: "klm = %@", argumentArray: [kilometer])
                    if let maxSortInfo = Info.MR_findFirstWithPredicate(predicateSort, sortedBy: "sort", ascending: false) {
                        info.sort = NSNumber(long: maxSortInfo.sort.longValue + 1)
                    }
                    if let userLocation = LocationManager.instance().lastLocation.value?.coordinate {
                        info.lat = userLocation.latitude
                        info.lon = userLocation.longitude
                    }
                    if let recordFile = self?.recordFile{
                        let userVoice = VoiceInfo.MR_createEntityInContext(context)
                        userVoice.info = info
                        userVoice.recordedVoice = NSData(contentsOfURL: recordFile)
                    }
                }
                })
        }
        else{
            NSLog("%@",error!)
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let info = fetchedController?.objectAtIndexPath(indexPath) as? Info {
            if let voiceInfo = info.voice {
                voicePlayer?.stop()
                AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
                voicePlayer = AVAudioPlayer(data: voiceInfo.recordedVoice, error: nil)
                voicePlayer?.delegate = self
                voicePlayer?.play()
            }
            else{
                if let infoViewController = self.storyboard?.instantiateViewControllerWithIdentifier("InfoAddViewController") as? InfoAddViewController {
                    infoViewController.info = info
                    infoViewController.road = info.klm.road
                    self.navigationController?.pushViewController(infoViewController, animated:false)
                }
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        voicePlayer?.stop()
        AVAudioSession.sharedInstance().setCategory(nil, error: nil)
    }
}
