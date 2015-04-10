//
//  VoiceInfo.swift
//  
//
//  Created by Eugene on 10/04/15.
//
//

import Foundation
import CoreData

class VoiceInfo: NSManagedObject {

    @NSManaged var recordedVoice: NSData
    @NSManaged var text: String
    @NSManaged var syntheseVoice: NSData
    @NSManaged var name: String
    @NSManaged var info: Info

}
