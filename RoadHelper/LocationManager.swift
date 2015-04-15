//
//  LocationManager.swift
//  RoadHelper
//
//  Created by Eugene on 14/04/15.
//  Copyright (c) 2015 Eugene Antropov. All rights reserved.
//

import UIKit
private let _LocationManagerSharedInstance = LocationManager()

class LocationManager:NSObject,CLLocationManagerDelegate{
    var haveAccess:Bool = {
        switch(CLLocationManager.authorizationStatus()){
        case .AuthorizedAlways,.AuthorizedWhenInUse:
            return true
        default:
            return false
        }
    }()
    
    let sharedLocationManager = CLLocationManager()
    var lastLocation = MutableProperty(Optional<CLLocation>.None)
    
    class func instance()->LocationManager {
        return _LocationManagerSharedInstance
    }
    
    override init() {
        super.init()
        sharedLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        sharedLocationManager.delegate = self
        
        self.startMonitoringLocation()
        
    }
    
    func askForLocationAccess() -> Void {
        if (sharedLocationManager.respondsToSelector(Selector("requestWhenInUseAuthorization"))) {
            sharedLocationManager.requestWhenInUseAuthorization()
        }
        else{
            sharedLocationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        self.startMonitoringLocation()
    }
    
    func startMonitoringLocation() {
        dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
            switch(CLLocationManager.authorizationStatus()){
            case .AuthorizedAlways,.AuthorizedWhenInUse:
                self?.haveAccess = true
                self?.sharedLocationManager.startUpdatingLocation()
            default:
                self?.haveAccess = false
            }
        })
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        lastLocation.value = newLocation
    }
    
    class func calculateDistanceBetwen(#rect:MKCoordinateRegion, userPoint:CLLocation) -> CLLocationDistance {
        let x = max(min(userPoint.coordinate.latitude,rect.center.latitude+(rect.span.latitudeDelta/2)),rect.center.latitude-(rect.span.latitudeDelta/2))
        let y = max(min(userPoint.coordinate.longitude,rect.center.longitude+(rect.span.longitudeDelta/2)),rect.center.longitude-(rect.span.longitudeDelta/2))
        let closestPoint = CLLocation(latitude: x, longitude: y)
        return closestPoint.distanceFromLocation(userPoint)
    }
    
    class func calculateDistanceBetwen(#point:CLLocationCoordinate2D, userPoint:CLLocation) -> CLLocationDistance {
        let closestPoint = CLLocation(latitude: point.latitude, longitude: point.longitude)
        return closestPoint.distanceFromLocation(userPoint)
    }
}
