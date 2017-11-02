//
//  Photo+CoreDataProperties.swift
//  Photorama
//
//  Created by Amado Diaz Jr on 7/10/17.
//  Copyright © 2017 Big Nerd Ranch. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var dateTaken: Date
    @NSManaged public var photoID: String
    @NSManaged public var photoKey: String
    @NSManaged public var remoteURL: URL
    @NSManaged public var title: String
    @NSManaged public var tags: Set<NSManagedObject>

}
