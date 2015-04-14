//
//  Info.swift
//  
//
//  Created by Eugene on 14/04/15.
//
//

import Foundation
import CoreData

class Info: NSManagedObject {

    @NSManaged var descr: String
    @NSManaged var maxLat: NSNumber?
    @NSManaged var maxLon: NSNumber?
    @NSManaged var minLat: NSNumber?
    @NSManaged var minLon: NSNumber?
    @NSManaged var name: String
    @NSManaged var sort: NSNumber
    @NSManaged var klm: Kilometr
    @NSManaged var photos: PhotoInfo

}
