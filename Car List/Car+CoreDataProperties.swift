//
//  Car+CoreDataProperties.swift
//  Car List
//
//  Created by Alex on 15.09.16.
//  Copyright © 2016 Alex Vydrin. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Car {

    @NSManaged var engine: String?
    @NSManaged var condition: String?
    @NSManaged var price: String?
    @NSManaged var model: String?
    @NSManaged var transmission: String?
    @NSManaged var carDescription: String?

}
