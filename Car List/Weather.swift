//
//  Weather.swift
//  Car List
//
//  Created by Alex on 15.09.16.
//  Copyright © 2016 Alex Vydrin. All rights reserved.
//

import Foundation
import CoreData


class Weather: NSManagedObject {
    
    func updateWith (weatherDict: [String:String?]) {
        self.city = weatherDict["city"] ?? nil
        self.weather = weatherDict["weather"] ?? nil
        self.temperature = weatherDict["temp"] ?? nil
        self.icon = weatherDict["icon"] ?? nil
        self.saveDataBase()
    }
    
    // Always only one weather in CoreData.
    class func getWeather (inManagedObjectContext context: NSManagedObjectContext) -> Weather? {
        let request = NSFetchRequest(entityName: "Weather")
        if let weather = try? context.executeFetchRequest(request).first as? Weather where weather != nil {
            return weather
        }
        // For the first time empty weather created.
        if let weather = NSEntityDescription.insertNewObjectForEntityForName("Weather", inManagedObjectContext: context) as? Weather {
            return weather
        }
        return nil
    }
}
