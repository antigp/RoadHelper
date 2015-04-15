//
//  VoiceInfo.swift
//  
//
//  Created by Eugene on 14/04/15.
//
//

import Foundation
import CoreData

class VoiceInfo: NSManagedObject {
    @NSManaged var recordedVoice: NSData?
    @NSManaged var info: Info

}
