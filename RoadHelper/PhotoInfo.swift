//
//  PhotoInfo.swift
//  
//
//  Created by Eugene on 14/04/15.
//
//

import Foundation
import CoreData

class PhotoInfo: NSManagedObject {

    @NSManaged var imageData: NSData
    @NSManaged var info: Info

}
