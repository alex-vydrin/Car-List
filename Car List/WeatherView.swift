//
//  WeatherView.swift
//  Car List
//
//  Created by Alex on 15.09.16.
//  Copyright © 2016 Alex Vydrin. All rights reserved.
//

import UIKit

class WeatherView: UIView {

    @IBOutlet var weatherLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var weatherIconView: UIImageView!
    
    class func instanceFromNib() -> WeatherView {
        return UINib(nibName: "WeatherViewXib", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! WeatherView
    }
    
    func updateWeather (weatherDict: [String:String?]) {
        cityLabel.text = weatherDict["city"]! ?? "--"
        tempLabel.text = weatherDict["temp"]! ?? "--"
        weatherLabel.text = weatherDict["weather"]! ?? ""
        weatherIconView.image = (UIImage(named: (weatherDict["icon"]! ?? "" )) ?? UIImage())
    }
    
    
    
    
}
