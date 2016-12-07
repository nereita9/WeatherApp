//
//  Weather.swift
//  WeatherApp
//
//  Created by Nerea Gonzalez Vazquez on 15/11/16.
//  Copyright © 2016 Nerea Gonzalez Vazquez. All rights reserved.
//

import Foundation
import UIKit

class City: NSObject, NSCoding {
    
    //MARK: Properties
    let name: String
    let id: Int
    let currentTemperature: Double?
    let humidity: Int?
    let wind: Double?
    let minTemp:Double?
    let maxTemp:Double?
    let weather: String?

    var weatherPic: UIImage?
    var weatherPicName: String?
    var weatherIconID: String?
    var weatherColor: UIColor?

    
    //MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("cities")
    
    //MARK: Types
    struct PropertyKey {
        static let nameKey = "name"
        static let idKey = "id"
     
    }

    
    //MARK: Initialization
    
    init(weatherData: [String: AnyObject]) {
        self.name = weatherData["name"] as! String
        self.id = weatherData["id"] as! Int
        


        
        let mainDictionary = weatherData["main"] as! [String: AnyObject]
        let exactTemperature = (mainDictionary["temp"] as! Double) - 273.15 //in celsius
        let minTemperature = (mainDictionary["temp_min"] as! Double) - 273.15 //in celsius
        let maxTemperature = (mainDictionary["temp_max"] as! Double) - 273.15 //in celsius
        self.humidity = mainDictionary["humidity"] as? Int
        self.currentTemperature = round(exactTemperature*10)/10 // only temperature with one decimal
        self.minTemp = round(minTemperature*10)/10 // only temperature with one decimal
        self.maxTemp = round(maxTemperature*10)/10 // only temperature with one decimal
       
        
        let windDictionary = weatherData["wind"] as! [String: AnyObject]
        let wind = (windDictionary["speed"] as! Double)
        self.wind = round(wind*10)/10
        
        
        let weatherArray = weatherData["weather"] as! [[String: AnyObject]]
        let weatherDictionary = weatherArray[0]
        self.weather = weatherDictionary["description"] as? String
        
        self.weatherIconID = weatherDictionary["icon"] as? String
        //preguntarlo cada vez en vez de guardarlo????
        self.weatherPic = nil
        self.weatherPicName = nil
        self.weatherColor = nil

        //need to call the superclass nscoding initializer
        super.init()
        
        self.weatherPic = weatherPicFunc().0
        self.weatherPicName = weatherPicFunc().1
        self.weatherColor = weatherColorFunc()

        
    }
    
    init(name: String, id: Int) {
        self.name = name
        self.id = id
    
        self.currentTemperature = nil
        self.humidity = nil
        self.wind = nil
        self.minTemp = nil
        self.maxTemp = nil
        self.weather = nil
        
        self.weatherIconID = nil

        self.weatherPic = nil
        self.weatherPicName = nil
        self.weatherColor = nil
    }
    
    
    
    
    //method for fetching a weather image
    func weatherPicFunc() -> (UIImage, String) {

        switch self.weatherIconID! {
        case "03d", "03n":
            return (UIImage(named: "03dn.png")!, "03dn")
        case "04d", "04n":
            return (UIImage(named: "04dn.png")!, "04dn")
        case "09d", "09n":
            return (UIImage(named: "09dn.png")!, "09dn")
        case "11d", "11n":
            return (UIImage(named: "11dn.png")!, "11dn")
        case "13d", "13n":
            return (UIImage(named: "13dn.png")!, "13dn")
        case "50d", "50n":
            return (UIImage(named: "50dn.png")!, "50dn")
        default:
            return (UIImage(named: "\(self.weatherIconID!).png")!, self.weatherIconID!)
        }
    }
    
     //method for fetching a weather color
    func weatherColorFunc() -> UIColor {
        
        switch self.weatherIconID! {
        case "01d": //yellow
            return UIColor(red: 231/255, green: 199/255, blue: 24/255, alpha:1)
        case "01n": //pink
            return UIColor(red: 166/255, green: 38/255, blue: 106/255, alpha:1)
        case "02d", "10d": //light blue
            return UIColor(red: 50/255, green: 190/255, blue: 188/255, alpha:1)
        case "02n", "10n": //light purple
            return UIColor(red: 142/255, green: 48/255, blue: 139/255, alpha:1)

        
        case "03d", "04d",  "09d", "11d", "13d": //dark blue
            return UIColor(red: 25/255, green: 95/255, blue: 165/255, alpha:1)

        case "03n", "04n", "09n", "11n", "13n": //dark purple
            return UIColor(red: 90/255, green: 25/255, blue: 94/255, alpha:1)
            
        case "50d", "50n": //grey
            return UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha:1)
        default:
           return UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha:1)
        }
    }


    
    
    //MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(id, forKey: PropertyKey.idKey)
        
        

    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let id = aDecoder.decodeObjectForKey(PropertyKey.idKey) as! Int
        self.init(name: name, id: id)
        
        
            
        
    }

    
    
}
