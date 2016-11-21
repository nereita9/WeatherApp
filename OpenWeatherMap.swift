//
//  OpenWeatherMap.swift
//  WeatherApp
//
//  Created by Nerea Gonzalez Vazquez on 21/11/16.
//  Copyright © 2016 Nerea Gonzalez Vazquez. All rights reserved.
//

import UIKit

class OpenWeatherMap {
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    private let openWeatherMapAPIKey = "4f6be5acd631049880c0b7b3c8c6c07b"
    
    func getWeather(city: String) {
        
        // This is a pretty simple networking task, so the shared session will do.
        let session = NSURLSession.sharedSession()
        
        let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        
        // The data task retrieves the data.
        let dataTask = session.dataTaskWithURL(weatherRequestURL) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let error = error {
                // Case 1: Error
                // We got some kind of error while trying to get data from the server.
                print("Error:\n\(error)")
            }
            else {
                // Case 2: Success
                // We got a response from the server!
                print("Data:\n\(data!)")
            }
        }
        
        // The data task is set up...launch it!
        dataTask.resume()
    }
    
}
