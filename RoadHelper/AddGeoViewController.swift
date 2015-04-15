//
//  AddGeoViewController.swift
//  RoadHelper
//
//  Created by Eugene on 15/04/15.
//  Copyright (c) 2015 Eugene Antropov. All rights reserved.
//

import UIKit

@objc
class userGeoPointAnnotation:NSObject,MKAnnotation{
     var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
}

class AddGeoViewController: UIViewController,MKMapViewDelegate {
    @IBOutlet weak private var mapView:MKMapView?
    private var annotation = userGeoPointAnnotation()
    var finishBlock:(CLLocationCoordinate2D -> Void)?

    
    var mapRect:MKCoordinateRegion?{
        didSet{
            reloadMapViewRect()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadMapViewRect()
        annotation.coordinate = mapRect?.center ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
        mapView?.addAnnotation(annotation)
        // Do any additional setup after loading the view.
    }

    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is userGeoPointAnnotation{
            let pinAnnotation  = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "UserEditPinAnontation")
            pinAnnotation.draggable = true
            return pinAnnotation
        }
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadMapViewRect() {
        if let mapRect = mapRect {
            mapView?.setRegion(mapRect, animated: true)
        }
    }
    
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if (newState == MKAnnotationViewDragState.Ending)
        {
            let droppedAt = view.annotation.coordinate;
        }
    }
    
    @IBAction func doneButtonPressed(){
        finishBlock?(annotation.coordinate)
        self.navigationController?.popViewControllerAnimated(true)
    }
}
