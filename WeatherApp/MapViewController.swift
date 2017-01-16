//
//  MapViewController.swift
//  WeatherApp
//
//  Created by Nerea Gonzalez Vazquez on 25/11/16.
//  Copyright © 2016 Nerea Gonzalez Vazquez. All rights reserved.
//

import UIKit
import MapKit

//MARK: CityAdditionDelegate
//Protocol that will be implemented by TableViewController
protocol CityAdditionDelegate: class {
    func cityAddition(newCity: City)
}

class MapViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var mapView: MKMapView!
    
    weak var delegate: CityAdditionDelegate?
    var noCitiesInFavorites: Bool?
    var mRect: MKMapRect?
    var weather: OpenWeatherMap!
    var city: City?
    var selectedCity: String?
    var cityId: Int?
    
    //MARK: Actions
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
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        weather = OpenWeatherMap(delegate: self)
        mapView.delegate = self

    }
    
}

//MARK: MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    //optimize memory
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.mapView.showsUserLocation = false
        self.mapView.delegate = nil
        self.mapView.removeFromSuperview()
        self.mapView = nil
    }
    
    //gets call first time mapView is loading and each time mapView view changes
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mRect = self.mapView.visibleMapRect
        
        //firstly remove annotations out of bounds, if dont the annotations will acumulate
        let allAnnotations = self.mapView.annotations
        for i in 0..<allAnnotations.count {
            let point = MKMapPointForCoordinate(allAnnotations[i].coordinate)
            if MKMapRectContainsPoint(mRect!, point) == false {
                self.mapView.removeAnnotation(allAnnotations[i])
                
            }
        }
        
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
        
        self.delegate?.cityAddition(city!)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

}
    

    


//MARK: OpenWeatherMapStationsDelegate
//MapViewController adopts the protocol defined in OpenWeatherMap
extension MapViewController: OpenWeatherMapStationsDelegate {

    func didGetStations(stations: [String: AnyObject]) {
        
        let stationsCount = stations["cnt"] as! Int
        let stationsList = stations["list"] as! [[String: AnyObject]]
        //dont load too much stations in the map
        let maxNewStations = 8
        let step = stationsCount/maxNewStations + 1
        
        for i in 0.stride(to: stationsCount, by: step) {
            let lon = stationsList[i]["coord"]!["lon"] as! Double
            let lat = stationsList[i]["coord"]!["lat"] as! Double
            let name = stationsList[i]["name"] as! String
            let id = stationsList[i]["id"] as! Int
            
            let annotation = CustomAnnotation(city: name, cityId: id, pinColor: UIColor.purpleColor())
            annotation.coordinate = CLLocationCoordinate2DMake(lat, lon)
            annotation.title = name
            
            
            dispatch_async(dispatch_get_main_queue()) {
                
                //only add annotation if not exists already (the new map view rectangle may have some stations in common with the previous rectangle)
                
                var isAnnotationAlreadyAdded = false
                for i in 0..<self.mapView.annotations.count {
                    
                    let currentAnnotation = self.mapView.annotations[i] as! CustomAnnotation
                    if currentAnnotation.cityId == annotation.cityId {
                        isAnnotationAlreadyAdded = true
                        break
                    }
                }
                if isAnnotationAlreadyAdded == false {
                    self.mapView.addAnnotation(annotation)
                }
                
            }
            
        }

    }
    
    func didNotGetStations(error: NSError) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            let alertVC = UIAlertController(title: "Can't get the weather stations", message: "The weather service isn't responding.", preferredStyle: .Alert)
            
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertVC.addAction(okAction)
            
            self.presentViewController(alertVC, animated: true, completion: nil)
            
        }
    }

}



