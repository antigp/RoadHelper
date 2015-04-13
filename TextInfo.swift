//
//  TextInfo.swift
//  
//
//  Created by Eugene on 13/04/15.
//
//

import Foundation
import CoreData

class TextInfo: NSManagedObject {

    @NSManaged var lat: NSNumber
    @NSManaged var lng: NSNumber
    @NSManaged var maxLat: NSNumber
    @NSManaged var maxLng: NSNumber
    @NSManaged var minLat: NSNumber
    @NSManaged var minLng: NSNumber
    @NSManaged var name: String
    @NSManaged var syntheseVoice: NSData
    @NSManaged var text: String
    @NSManaged var info: Info

}
