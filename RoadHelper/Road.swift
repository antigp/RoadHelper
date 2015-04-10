//
//  Road.swift
//  
//
//  Created by Eugene on 10/04/15.
//
//

import Foundation
import CoreData

class Road: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var totalKLM: NSNumber
    @NSManaged var infos: NSSet

}
