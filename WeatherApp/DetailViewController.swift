//
//  DetailViewController.swift
//  WeatherApp
//
//  Created by Nerea Gonzalez Vazquez on 15/11/16.
//  Copyright © 2016 Nerea Gonzalez Vazquez. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
   
    //MARK: Properties
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    

    
    //necessary because in ipad the tableView is in the same view as the detailview, so it is not enought to update in viewdidload
    
    var city: City! {
        didSet (newCity){
            
        

                self.refreshUI()
            
        }
    }
    
    func refreshUI(){
        
            nameLabel?.text = city.name
            temperatureLabel?.text = String(city.temperature)
            weatherLabel?.text = city.weatherDescription
            iconImageView?.image = city.weatherPic
            
            
        
    }
    

    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshUI()
    
        

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
    


}


extension DetailViewController: CitySelectionDelegate{
    func citySelected(newCity: City) {
        
        self.city = newCity
    }
}

