//
//  TableViewController.swift
//  WeatherApp
//
//  Created by Nerea Gonzalez Vazquez on 15/11/16.
//  Copyright © 2016 Nerea Gonzalez Vazquez. All rights reserved.
//

import UIKit


protocol CitySelectionDelegate: class {
    func citySelected(newCity: City)
}

class TableViewController: UITableViewController {
    
    var cities = [City]()
    
    weak var delegate: CitySelectionDelegate?
    
    //this willbe loaded from a storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        //load any saved meals, otherwise load sample data
        if let savedCities = loadCities() {
            cities+=savedCities
        }
        else {
            loadSampleCities()
        }
    }
    
    func loadSampleCities(){
        
        self.cities.append(City(name:"Paris", temperature: 20, weather: 0))
        self.cities.append(City(name:"Madrid", temperature: 30, weather: 1))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // editbutton in the navigation bar for deleting
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        //add button in the navigation bar
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(insertNewCity(_:)))
        self.navigationItem.rightBarButtonItem = addButton

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    
    func insertNewCity(sender: AnyObject?)
    {
        print("insert new city")
        // .....
        //... google maps
        //...
        
        //cities.append(newCity)
        
        //  //save Cities in MEM
        //saveCities()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cities.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        // Configure the cell...
        let city = self.cities[indexPath.row]
        cell.textLabel?.text = city.name
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCity = self.cities[indexPath.row]
        self.delegate?.citySelected(selectedCity)
        if let detailViewController = self.delegate as? DetailViewController {
            
            //MARK:super important
            //show the detailviewcontroller nstead of the navigation controller to avoid the size classes variation probles
            splitViewController?.showDetailViewController(detailViewController, sender: nil)
        }
        

    }
     

    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            cities.removeAtIndex(indexPath.row)
            
            //save cities in MEM
            saveCities()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

        if segue.identifier == "showDetail" {
            let navViewController = segue.destinationViewController as! UINavigationController
            let detailViewController = navViewController.topViewController as! DetailViewController
            if let selectedCityCell = sender as? CityTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedCityCell)!
                let selectedCity = cities[indexPath.row]
                detailViewController.city = selectedCity
                
            }
        }
    }*/
    
    
    //MARK: NSCoding
    func saveCities() {
        let isSuccesfulSave = NSKeyedArchiver.archiveRootObject(cities, toFile: City.ArchiveURL.path!)
        if !isSuccesfulSave { print("Failed to save meals....") }
    }
    
    func loadCities() -> [City]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(City.ArchiveURL.path!) as? [City]
    }
/*
    func setOverrideTraitCollection(collection: UITraitCollection?, forChildViewController childViewController: UIViewController) {
        childViewController.class
    }
  */  

}
