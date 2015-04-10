//
//  TextInfo.swift
//  
//
//  Created by Eugene on 10/04/15.
//
//

import Foundation
import CoreData

class TextInfo: NSManagedObject {

    @NSManaged var text: String
    @NSManaged var syntheseVoice: NSData
    @NSManaged var name: String
    @NSManaged var info: Info

}
