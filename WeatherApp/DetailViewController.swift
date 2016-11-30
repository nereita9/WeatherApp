//
//  DetailViewController.swift
//  WeatherApp
//
//  Created by Nerea Gonzalez Vazquez on 15/11/16.
//  Copyright © 2016 Nerea Gonzalez Vazquez. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, OpenWeatherMapDelegate {
   
    //MARK: Properties
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    var weather: OpenWeatherMap!
    var initDelegate = true
    
    //necessary because in ipad the tableView is in the same view as the detailview, so it is not enought to update in viewdidload
    var city: City! {
        didSet (newCity){
            
            if initDelegate == true{
                weather = OpenWeatherMap(delegate: self)
                initDelegate = false
            }
            
                self.refreshUI()
        }
    }
    
    func refreshUI(){
        
        weather.getWeatherById(city.id)
        print("UI refreshed")
        
    }
    
    //Actions
    @IBAction func refreshData(sender: UIBarButtonItem) {
        refreshUI()
        //print("refreshing")
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        if self.city != nil {
            self.refreshUI()
        }
        print("refreshing after passing from background to active")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //when Favorites is empty in ipad landscape detail view is shown a little before launching maps, better see white screen that the default labels..
        self.nameLabel?.text = nil
        self.temperatureLabel?.text = nil
        self.weatherLabel?.text = nil

        
        //observe when the application opens from background
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: #selector(self.applicationDidBecomeActive(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        //if there are already a city asigned, in case table view empty no city asgned (it may happen)!!!
        //if city != nil {
         //   refreshUI()
        //}
        
        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    
    // MARK: WeatherGetterDelegate methods
    // -----------------------------------
    
    func didGetWeather(city: City) {
        // This method is called asynchronously, which means it won't execute in the main queue.
        // ALl UI code needs to execute in the main queue, which is why we're wrapping the code
        // that updates all the labels in a dispatch_async() call.
        dispatch_async(dispatch_get_main_queue()) {
            
            self.nameLabel?.text = city.name
            self.temperatureLabel?.text = String(city.temperature!)+" ºC"
            self.weatherLabel?.text = city.weather!.capitalizedString
            
            self.iconImageView?.image = city.weatherPic!
            self.iconImageView?.image = self.iconImageView?.image!.imageWithRenderingMode(.AlwaysTemplate)
            self.iconImageView?.tintColor = UIColor.whiteColor()
            
            UIView.animateWithDuration(0.3, animations: {Void in
                self.view.backgroundColor = city.weatherColor
            })

            
        }
    }
    
    func didNotGetWeather(error: NSError) {
        // This method is called asynchronously, which means it won't execute in the main queue.
        // ALl UI code needs to execute in the main queue, which is why we're wrapping the call
        // to showSimpleAlert(title:message:) in a dispatch_async() call.
        dispatch_async(dispatch_get_main_queue()) {
           
            let alertVC = UIAlertController(title: "Can't get the weather", message: "The weather service isn't responding.", preferredStyle: .Alert)
            
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertVC.addAction(okAction)
            
            self.presentViewController(alertVC, animated: true, completion: nil)

            
            
        }
       
    }
    
    func alertControllerBackgroundTapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    


}


extension DetailViewController: CitySelectionDelegate{
    func citySelected(newCity: City) {
        
        self.city = newCity
    }
}

