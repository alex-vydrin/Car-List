//
//  Weather+CoreDataProperties.swift
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

extension Weather {

    @NSManaged var temperature: String?
    @NSManaged var icon: String?
    @NSManaged var city: String?
    @NSManaged var weather: String?

}
