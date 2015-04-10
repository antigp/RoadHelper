//
//  PhotoInfo.swift
//  
//
//  Created by Eugene on 10/04/15.
//
//

import Foundation
import CoreData

class PhotoInfo: NSManagedObject {

    @NSManaged var imageData: NSData
    @NSManaged var name: String
    @NSManaged var info: Info

}
