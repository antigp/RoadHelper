//
//  Info.swift
//  
//
//  Created by Eugene on 10/04/15.
//
//

import Foundation
import CoreData

class Info: NSManagedObject {

    @NSManaged var klm: NSNumber
    @NSManaged var road: Road
    @NSManaged var geoInfo: GeoInfo
    @NSManaged var photoInfo: PhotoInfo
    @NSManaged var textInfo: TextInfo
    @NSManaged var voiceInfo: VoiceInfo

}
