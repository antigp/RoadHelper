//
//  GeoInfo.swift
//  
//
//  Created by Eugene on 10/04/15.
//
//

import Foundation
import CoreData

class GeoInfo: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var lat: NSNumber
    @NSManaged var lng: NSNumber
    @NSManaged var info: Info

}
