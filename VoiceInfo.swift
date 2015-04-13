//
//  VoiceInfo.swift
//  
//
//  Created by Eugene on 13/04/15.
//
//

import Foundation
import CoreData

class VoiceInfo: NSManagedObject {

    @NSManaged var lat: NSNumber
    @NSManaged var lng: NSNumber
    @NSManaged var recordedVoice: NSData
    @NSManaged var info: Info

}
