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
    
        
        weather.getWeather(city.name)
        
    }
    
    //Actions
    @IBAction func refreshData(sender: UIBarButtonItem) {
        refreshUI()
        //print("refreshing")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //if there are already a city asigned, in case table view empty no city asgned (it may happen)!!!
        if city != nil {
            refreshUI()
        }
        

        // Do any additional setup after loading the view.
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
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
        print("didNotGetWeather error: \(error)")
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

