//
//  Kilometr.swift
//  
//
//  Created by Eugene on 14/04/15.
//
//

import Foundation
import CoreData

class Kilometr: NSManagedObject {

    @NSManaged var klm: NSNumber
    @NSManaged var infos: NSSet
    @NSManaged var road: Road
    @NSManaged var voices: NSSet

}