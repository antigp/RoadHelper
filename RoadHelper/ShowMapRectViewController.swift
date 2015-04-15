//
//  ShowMapRectViewController.swift
//  RoadHelper
//
//  Created by Eugene on 15/04/15.
//  Copyright (c) 2015 Eugene Antropov. All rights reserved.
//

import UIKit

class ShowMapRectViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView:MKMapView?
    var mapRect:MKCoordinateRegion?{
        didSet{
            reloadMapViewRect()
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        var overlayPathView = MKPolygonRenderer(overlay: overlay)
        overlayPathView.fillColor = UIColor.greenColor().colorWithAlphaComponent(0.2)
        overlayPathView.strokeColor = UIColor.redColor().colorWithAlphaComponent(0.2)
        overlayPathView.lineWidth = 1
        
        return overlayPathView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadMapViewRect()
        // Do any additional setup after loading the view.
    }

    func reloadMapViewRect() {
        if let mapRect = mapRect {
            var points: [CLLocationCoordinate2D] = []
            points.append(CLLocationCoordinate2D(latitude: mapRect.center.latitude - (mapRect.span.latitudeDelta/2), longitude: mapRect.center.longitude - (mapRect.span.longitudeDelta/2)))
            points.append(CLLocationCoordinate2D(latitude: mapRect.center.latitude - (mapRect.span.latitudeDelta/2), longitude: mapRect.center.longitude + (mapRect.span.longitudeDelta/2)))
            points.append(CLLocationCoordinate2D(latitude: mapRect.center.latitude + (mapRect.span.latitudeDelta/2), longitude: mapRect.center.longitude + (mapRect.span.longitudeDelta/2)))
            points.append(CLLocationCoordinate2D(latitude: mapRect.center.latitude + (mapRect.span.latitudeDelta/2), longitude: mapRect.center.longitude - (mapRect.span.longitudeDelta/2)))
            let polygon = MKPolygon(coordinates: &points, count: 4)
            mapView?.addOverlay(polygon)
            mapView?.setRegion(mapRect, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
