//
//  Weather.swift
//  WeatherApp
//
//  Created by Nerea Gonzalez Vazquez on 15/11/16.
//  Copyright © 2016 Nerea Gonzalez Vazquez. All rights reserved.
//

import UIKit

class City: NSObject, NSCoding {
    
    //MARK: Properties
    let name: String
    let weather: Int
    let temperature: Double
    var weatherPic: UIImage?
    var weatherDescription: String?
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("cities")
    
    //MARK: Types
    struct PropertyKey {
        static let nameKey = "name"
        static let weatherKey = "weather"
        static let temperatureKey = "temperature"
        static let weatherPicKey = "weatherPic"
        static let weatherDescriptionKey = "weatherDescription"
    }

    
    //MARK: Initialization
    init(name: String, temperature: Double, weather: Int) { //it can return nil
        self.name = name
        self.temperature = temperature
        self.weather = weather
        
        //preguntarlo cada vez en vez de guardarlo????
        self.weatherPic = nil
        self.weatherDescription = nil

        //need to call the superclass nscoding initializer
        super.init()
        
        self.weatherPic = weatherInterpretation().0!
        self.weatherDescription = weatherInterpretation().1

        
        
    }
    
  
    
    //method for fetching a weather image
    func weatherInterpretation() -> (UIImage?, String) {
        switch self.weather {
        case 0:
            return (UIImage(named: "cloudy.png"), "Cloudy")
        case 1:
            return (UIImage(named: "sunny.png"), "Sunny")
        default:
            return (UIImage(named: "night.png"), "Night")
        }
    }
    
    
    //MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(temperature, forKey: PropertyKey.temperatureKey)
        aCoder.encodeObject(weather, forKey: PropertyKey.weatherKey)
        //aCoder.encodeObject(weatherPic, forKey: PropertyKey.weatherPicKey)
        //aCoder.encodeObject(weatherDescription, forKey: PropertyKey.weatherDescriptionKey)

    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        //photo is optional
        let temperature = aDecoder.decodeObjectForKey(PropertyKey.temperatureKey) as! Double
        
        let weather = aDecoder.decodeObjectForKey(PropertyKey.weatherKey) as! Int
        
        //let weatherPic = aDecoder.decodeObjectForKey(PropertyKey.weatherPicKey) as! UIImage
        
        //let weatherDescription = aDecoder.decodeObjectForKey(PropertyKey.weatherDescriptionKey) as! String
        
        //as convenience initializer it must call one of the class initializer
        self.init(name: name, temperature: temperature, weather: weather)
        
    }

    
    
}
