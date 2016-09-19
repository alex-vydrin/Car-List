//
//  Images.swift
//  Car List
//
//  Created by Alex on 15.09.16.
//  Copyright © 2016 Alex Vydrin. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class Images: NSManagedObject {

    class func createImage (newImage: UIImage, forCar car: Car, inManagedObjectContext context: NSManagedObjectContext) {
        if let image = NSEntityDescription.insertNewObjectForEntityForName("Images", inManagedObjectContext: context) as? Images {
            image.image = UIImageJPEGRepresentation(newImage, 1)
            image.car = car
            image.saveDataBase()
        }
    }
    
    class func getImagesFor (car: Car, inManagedObjectContext context: NSManagedObjectContext) -> [UIImage]? {
        let request = NSFetchRequest(entityName: "Images")
        request.predicate = NSPredicate(format: "car = %@", car)
        
        if let images = try? context.executeFetchRequest(request) as? [Images] {
            let carImages = images!.map { UIImage(data: $0.image!) ?? UIImage(named: "no car")! }
            return carImages
        }
        return nil
    }
}
