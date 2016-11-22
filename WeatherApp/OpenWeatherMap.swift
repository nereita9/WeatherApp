//
//  OpenWeatherMap.swift
//  WeatherApp
//
//  Created by Nerea Gonzalez Vazquez on 21/11/16.
//  Copyright © 2016 Nerea Gonzalez Vazquez. All rights reserved.
//

import UIKit


// MARK: OpenWeatherMapDelegate
// ===========================
// OpenWeatherMap should be used by a class or struct, and that class or struct
// should adopt this protocol and register itself as the delegate.
// The delegate's didGetWeather method is called if the weather data was
// acquired from OpenWeatherMap.org and successfully converted from JSON into
// a Swift dictionary.
// The delegate's didNotGetWeather method is called if either:
// - The weather was not acquired from OpenWeatherMap.org, or
// - The received weather data could not be converted from JSON into a dictionary.
protocol OpenWeatherMapDelegate {
    func didGetWeather(city: City)
    func didNotGetWeather(error: NSError)
}


class OpenWeatherMap {
    
    private let baseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let myAPIKey = "4f6be5acd631049880c0b7b3c8c6c07b"
    
    private var delegate:  OpenWeatherMapDelegate
    
    
    init(delegate: OpenWeatherMapDelegate) {
        self.delegate = delegate
    }
    
    
    
    func getWeather(city: String){
        
        // This is a pretty simple networking task, so the shared session will do.
        let session = NSURLSession.sharedSession()
        
        let weatherRequestURL = NSURL(string: "\(baseURL)?APPID=\(myAPIKey)&q=\(city)")!
        
        // The data task retrieves the data. {() in } syntax equivalent to dataTaskWithURL(weatherRequestURL, completion: {(.....) in ..handler func name or code directly....})
        let dataTask = session.dataTaskWithURL(weatherRequestURL) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let error = error {
                // Case 1: Error
                // An error occurred while trying to get data from the server.
                self.delegate.didNotGetWeather(error)
            }
            else {
                // Case 2: Success
                // We got a response from the server!
                
                do {
                    // Try to convert that JSON data into a Swift dictionary
                    let weather = try NSJSONSerialization.JSONObjectWithData(
                        data!,
                        options: .MutableContainers) as! [String: AnyObject]
                    
                    // If we made it to this point, we've successfully converted the
                    // JSON-formatted weather data into a Swift dictionary.
                    // Let's now used that dictionary to initialize a Weather struct.

                    let city = City(weatherData: weather)
                    
                    // Now that we have the Weather struct, let's notify the view controller,
                    // which will use it to display the weather to the user.
                    self.delegate.didGetWeather(city)

                    // Let's print its contents to the debug console.
                    
                    //anyObject! you are storing is an optional, and dictionaries retireves also the optional of the storage value so !!
                    /*print("Date and time: \(weather["dt"]!)")
                    print("City: \(weather["name"]!)")
                    
                    print("Longitude: \(weather["coord"]!["lon"]!!)")
                    print("Latitude: \(weather["coord"]!["lat"]!!)")
                    
                    print("Weather ID: \(weather["weather"]![0]!["id"]!!)")
                    print("Weather main: \(weather["weather"]![0]!["main"]!!)")
                    print("Weather description: \(weather["weather"]![0]!["description"]!!)")
                    print("Weather icon ID: \(weather["weather"]![0]!["icon"]!!)")
                    
                    print("Temperature: \(weather["main"]!["temp"]!!)")
                    print("Humidity: \(weather["main"]!["humidity"]!!)")
                    print("Pressure: \(weather["main"]!["pressure"]!!)")
                    
                    print("Cloud cover: \(weather["clouds"]!["all"]!!)")
                    
                    print("Wind direction: \(weather["wind"]!["deg"]!!) degrees")
                    print("Wind speed: \(weather["wind"]!["speed"]!!)")
                    
                    print("Country: \(weather["sys"]!["country"]!!)")
                    print("Sunrise: \(weather["sys"]!["sunrise"]!!)")
                    print("Sunset: \(weather["sys"]!["sunset"]!!)")
                    */
                    
                }
                catch let jsonError as NSError {
                    // An error occurred while trying to convert the data into a Swift dictionary.
                    self.delegate.didNotGetWeather(jsonError)
                }
                
                
                
            }
        }
        
        // The data task is set up...launch it!
        dataTask.resume()
    }
    
}
