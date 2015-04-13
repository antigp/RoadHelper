//
//  Info.swift
//  
//
//  Created by Eugene on 13/04/15.
//
//

import Foundation
import CoreData

class Info: NSManagedObject {

    @NSManaged var photoInfo: PhotoInfo
    @NSManaged var textInfo: TextInfo
    @NSManaged var voiceInfo: VoiceInfo
    @NSManaged var klm: NSManagedObject

}
