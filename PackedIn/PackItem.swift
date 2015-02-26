//
//  PackItem.swift
//  PackedIn
//
//  Created by Yuan Chen on 26/2/15.
//  Copyright (c) 2015 Yuan Chen. All rights reserved.
//

import Foundation
import CoreData

class PackItem: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var stats: NSNumber
    @NSManaged var belongTo: PackList

}
