//
//  MapViewController.swift
//  WeatherApp
//
//  Created by Nerea Gonzalez Vazquez on 25/11/16.
//  Copyright © 2016 Nerea Gonzalez Vazquez. All rights reserved.
//

import UIKit
import MapKit

protocol CityAdditionDelegate: class {
    func cityAddition(newCity: City)
}

class MapViewController: UIViewController, OpenWeatherMapStationsDelegate, MKMapViewDelegate {
    
    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    
    weak var delegate: CityAdditionDelegate?
    var noCitiesInFavorites: Bool?
    
    var mRect: MKMapRect?
    
    var weather: OpenWeatherMap!
    
    var city: City?
    
    var selectedCity: String?
    var cityId: Int?
    
    
    
    
    @IBAction func mapsCancel(sender: UIBarButtonItem) {
        if noCitiesInFavorites == true {
            //if there are no cities in favorites user must select a city in the map, cannot cancel
            dispatch_async(dispatch_get_main_queue()) {
                
                let alertVC = UIAlertController(title: "You must select one city in the map", message: "There are no stored cities in Favorites.", preferredStyle: .Alert)
                
                
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                
                alertVC.addAction(okAction)
                
                self.presentViewController(alertVC, animated: true, completion: nil)
                
                
                
            }

        }
        else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weather = OpenWeatherMap(delegate: self)
        mapView.delegate = self
        
        
    
    }
    
    

    
    //gets call first time mapView is loading and each time mapView view changes
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        

        mRect = self.mapView.visibleMapRect
        
        let bottomLeft: CLLocationCoordinate2D
        let topRight: CLLocationCoordinate2D
        
        bottomLeft = MKCoordinateForMapPoint(MKMapPointMake(mRect!.origin.x, MKMapRectGetMaxY(mRect!)))
        topRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mRect!), mRect!.origin.y))
        
        weather.getSations(bottomLeft.longitude, latitudeP1: bottomLeft.latitude, longitudeP2: topRight.longitude, latitudeP2: topRight.latitude)
  

        
    }
    //to be able to have custom pin color
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            let customAnnotation = annotation as! CustomAnnotation
            pinView?.pinTintColor = customAnnotation.pinColor
            
            pinView?.canShowCallout = false //important for the handle when selecting an annotation
            
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    //handle annotation view selection
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        let annotation = view.annotation as! CustomAnnotation
        selectedCity = annotation.city
        cityId = annotation.cityId
       
        
        
        city = City(name: selectedCity!, id: cityId!)
        
        //importantttt check if delegate implements protocol 
        self.delegate?.cityAddition(city!)
        self.dismissViewControllerAnimated(true, completion: nil)
        

        
        
        
    }
    
    
    

    
    func didGetStations(stations: [String: AnyObject]) {
        // This method is called asynchronously, which means it won't execute in the main queue.
        // ALl UI code needs to execute in the main queue, which is why we're wrapping the code
        // that updates all the labels in a dispatch_async() call.
        
        //print(stations)
        
        let stationsCount = stations["cnt"] as! Int
        let stationsList = stations["list"] as! [[String: AnyObject]]
        
        //print(stationsCount)
         //print("-----------------------------------------------------")
        
        for i in 0..<stationsCount {
            let lon = stationsList[i]["coord"]!["lon"] as! Double
            let lat = stationsList[i]["coord"]!["lat"] as! Double
            let name = stationsList[i]["name"] as! String
            let id = stationsList[i]["id"] as! Int
            
            //print("\(name): \(lat), \(lon)")
            
            
            let annotation = CustomAnnotation(city: name, cityId: id, pinColor: UIColor.purpleColor())
            annotation.coordinate = CLLocationCoordinate2DMake(lat, lon)
            annotation.title = name
            

            dispatch_async(dispatch_get_main_queue()) {
                
                 self.mapView.addAnnotation(annotation)
                
            }
            
           
            
        }
        
        // print("-----------------------------------------------------")


    }
    
    func didNotGetStations(error: NSError) {
        // This method is called asynchronously, which means it won't execute in the main queue.
        // ALl UI code needs to execute in the main queue, which is why we're wrapping the call
        // to showSimpleAlert(title:message:) in a dispatch_async() call.
        dispatch_async(dispatch_get_main_queue()) {
            
            let alertVC = UIAlertController(title: "Can't get the weather stations", message: "The weather service isn't responding.", preferredStyle: .Alert)
            
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertVC.addAction(okAction)
            
            self.presentViewController(alertVC, animated: true, completion: nil)
            
            
            
        }
        print("didNotGetWeather error: \(error)")
    }

    


    
}




