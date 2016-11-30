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

protocol OpenWeatherMapStationsDelegate {
    func didGetStations(stations: [String: AnyObject])
    func didNotGetStations(error: NSError)
}


class OpenWeatherMap {
    
    private let baseURL = "http://api.openweathermap.org/data/2.5"
    private let myAPIKey = "4f6be5acd631049880c0b7b3c8c6c07b"
    
    private var delegate:  OpenWeatherMapDelegate!
    
    private var stationsDelegate:  OpenWeatherMapStationsDelegate!
    
    init(delegate: OpenWeatherMapDelegate) {
        self.delegate = delegate
    }
    
    init(delegate: OpenWeatherMapStationsDelegate) {
        self.stationsDelegate = delegate
    }
    

    
    func getWeatherById(id: Int) {
        let weatherRequestURL = NSURL(string: "\(baseURL)/weather?APPID=\(myAPIKey)&id=\(id)")!
        getWeather(weatherRequestURL)
    }

    
    func getWeather(weatherRequestURL: NSURL){
        
        // This is a pretty simple networking task, so the shared session will do.
        let session = NSURLSession.sharedSession()
        
        //let weatherRequestURL = NSURL(string: "\(baseURL)?APPID=\(myAPIKey)&q=\(city)")!
        
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
    
    
    
    
    func getSations(longitudeP1: Double, latitudeP1: Double, longitudeP2: Double, latitudeP2: Double){
        let stationsRequestURL = NSURL(string: "\(baseURL)/box/city?APPID=\(myAPIKey)&bbox=\(longitudeP1),\(latitudeP1),\(longitudeP2),\(latitudeP2)&cluster=yes")!
        
        //print("search: \(longitudeP1),\(latitudeP1),\(longitudeP2),\(latitudeP2)")
    
        // This is a pretty simple networking task, so the shared session will do.
        let session = NSURLSession.sharedSession()
        
        //let weatherRequestURL = NSURL(string: "\(baseURL)?APPID=\(myAPIKey)&q=\(city)")!
        
        // The data task retrieves the data. {() in } syntax equivalent to dataTaskWithURL(weatherRequestURL, completion: {(.....) in ..handler func name or code directly....})
        print("SENDING REQUEST: \n \(stationsRequestURL)")
        let dataTask = session.dataTaskWithURL(stationsRequestURL) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let error = error {
                // Case 1: Error
                // An error occurred while trying to get data from the server.
                self.stationsDelegate.didNotGetStations(error)
            }
            else {
                // Case 2: Success
                // We got a response from the server!
            
                print("RESPONSE: \n ")
                do {
                    // Try to convert that JSON data into a Swift dictionary
                    let stations = try NSJSONSerialization.JSONObjectWithData(
                        data!,
                        options: .MutableContainers) as! [String: AnyObject]
                    
                    // Now that we have the Weather struct, let's notify the view controller,
                    // which will use it to display the weather to the user.
                    self.stationsDelegate.didGetStations(stations)
                    
                    
                }
                catch let jsonError as NSError {
                    // An error occurred while trying to convert the data into a Swift dictionary.
                    //Dont do nathing maybe the reaponse is empty because we are in the ocean an tere are no stations
                    print(jsonError)
                    //self.stationsDelegate.didNotGetStations(jsonError)
                }
                
                
                
            }
        }
        
        // The data task is set up...launch it!
        dataTask.resume()
        
    }
    
    
}
