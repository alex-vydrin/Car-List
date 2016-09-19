//
//  Car.swift
//  Car List
//
//  Created by Alex on 15.09.16.
//  Copyright © 2016 Alex Vydrin. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Car: NSManagedObject {

    class func createRecordFrom (carInfo: [String:String], images: [UIImage], inManagedObjectContext context: NSManagedObjectContext) {
        if let car = NSEntityDescription.insertNewObjectForEntityForName("Car", inManagedObjectContext: context) as? Car {
            car.model = carInfo["model"]
            car.price = carInfo["price"]
            car.engine = carInfo["engine"]
            car.transmission = carInfo["transmission"]
            car.condition = carInfo["condition"]
            car.carDescription = carInfo["description"]
            images.forEach{ Images.createImage($0, forCar: car, inManagedObjectContext: context) }
            car.saveDataBase()
        }
    }
    
    class func getRecordWithModel (model: String, inManagedObjectContext context: NSManagedObjectContext) -> Car? {
        let request = NSFetchRequest(entityName: "Car")
        request.predicate = NSPredicate(format: "model = %@", model)
        
        if let record = (try? context.executeFetchRequest(request))?.first as? Car {
            return record
        }
        return nil
    }
    
    class func getAllRecords (model: String, inManagedObjectContext context: NSManagedObjectContext) -> [Car]? {
        let request = NSFetchRequest(entityName: "Car")
        request.predicate = NSPredicate(format: "any")
        
        if let record = try? context.executeFetchRequest(request) as? [Car] {
            return record
        }
        return nil
    }
    
}


