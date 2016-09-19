//
//  WeatherManager.swift
//  Car List
//
//  Created by Alex on 15.09.16.
//  Copyright © 2016 Alex Vydrin. All rights reserved.
//

import Foundation
import SwiftOpenWeatherMapAPI
import CoreLocation

class WeatherManager: NSObject {
    
    let weatherAPI = WAPIManager(apiKey: "1ede3b2700dc943e240584c75820cae0", temperatureFormat: .Celsius, lang: NSBundle.mainBundle().preferredLocalizations.first == "ru" ? .Russian : .English)
    let context = ((UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext)!
    
    func getCurrentWeather (location: CLLocation?, completion:(result:[String:String?]) -> Void) -> [String:String?] {
        
        if location != nil {
            let weather = Weather.getWeather(inManagedObjectContext: context)
            var dict = [String:String?]()
            var semaphore = 0
            
            weatherAPI.currentWeatherByCoordinatesAsJson(location!.coordinate) { (WeatherResult) in
                switch WeatherResult {
                case .Success(let json):
                    dict["weather"] = json["weather"][0]["main"].rawValue as? String
                    if let temp = json["main"]["temp"].rawValue as? Int {
                        dict["temp"] = String(temp)
                    }
                    dict["icon"] = json["weather"][0]["icon"].rawValue as? String
                    semaphore += 1
                    if semaphore == 2 {
                        weather?.updateWith(dict)
                        completion(result: dict)
                    }
                default:
                    dict["weather"] = nil
                    dict["temp"] = nil
                    dict["icon"] = nil
                    semaphore += 1
                    if semaphore == 2 {
                        weather?.updateWith(dict)
                        completion(result: dict)
                    }
                }
            }
            
            CLGeocoder().reverseGeocodeLocation(location!) { (placemarks, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                if placemarks?.count > 0 {
                    let pm = placemarks![0] as CLPlacemark
                    dict["city"] = pm.locality
                } else {
                    dict["city"] = nil
                    print("Problem with the data received from geocoder")
                }
                
                semaphore += 1
                if semaphore == 2 {
                    weather?.updateWith(dict)
                    completion(result: dict)
                }
            }
        }
        
        // Returns first, while requests are handled.
        let lastWeather = Weather.getWeather(inManagedObjectContext: context)
        let lastWeatherDict = ["city":lastWeather?.city, "temp":lastWeather?.temperature, "weather":lastWeather?.weather, "icon":lastWeather?.icon]
        return lastWeatherDict
    }
}
