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

class TableViewController: UITableViewController{
    
   
    
    var currentSelectedIndexPath: NSIndexPath?
    
    var cities = [City]()
    
    
    var city: City! {
        didSet (newCity){
            
            self.refreshTable()
            
            self.presentDetailViewControllerWithSelectedCity()
            
        }
    }
    
    func cityAlreadySaved(id: Int) -> Int? {
        for i in 0..<cities.count {
            if cities[i].id == id {
                return i
            }
        }
        return nil
    }
    
    func refreshTable(){
        let existingCityRow = cityAlreadySaved(city.id)
        if existingCityRow != nil {
            let existingCity = cities[existingCityRow!]
            
            self.cities.removeAtIndex(existingCityRow!)
            self.cities.insert(existingCity, atIndex: 0)
            
            //save cities in MEM
            tableView.reloadData()
           
            self.delegate?.citySelected(existingCity)
            
        }
        else {
            
            self.cities.insert(city, atIndex: 0)
            //save cities in MEM
            tableView.reloadData()
            self.delegate?.citySelected(city)
            
        }
        
        
    }
    
    func presentDetailViewControllerWithSelectedCity(){
        
        if let detailViewController = self.delegate as? DetailViewController {
            
            
            
            
            if ( (UIDevice.currentDevice().userInterfaceIdiom == .Pad) || (UIDevice.currentDevice().userInterfaceIdiom == .Phone && UIScreen.mainScreen().nativeBounds.height == 2208 ) ){

                //hide master view (table view) when clicking. In ipad portrait
                if ( (UIDevice.currentDevice().userInterfaceIdiom == .Pad) && (UIDevice.currentDevice().orientation == .Portrait || UIDevice.currentDevice().orientation == .PortraitUpsideDown)){
                    
                    
                    UIView.animateWithDuration(0.3, animations: {
                        self.splitViewController?.preferredDisplayMode = .PrimaryHidden
                        }, completion: { finished in
                            //restore
                            self.splitViewController?.preferredDisplayMode = .Automatic
                    })
  
                    
                }
                else {
                    // print("ipad or iphone 6 plus")
                    
                    splitViewController?.showDetailViewController(detailViewController.navigationController!,sender: nil)
                }
                
                
            }
            else {
                //MARK:super important
                //show the detailviewcontroller instead of the navigation controller to avoid the size classes variation probles
                //print("iphone")
                splitViewController?.showDetailViewController(detailViewController, sender: nil)
            }
        }

    }


    
    weak var delegate: CitySelectionDelegate?
    
    var weather: OpenWeatherMap!
    
    var firstLaunch = true
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
        
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let mapNavViewController = segue.destinationViewController as! UINavigationController
        let mapViewController = mapNavViewController.topViewController as! MapViewController
        mapViewController.delegate = self
       
        if sender === addButton {
            mapViewController.title = "Map"
            mapViewController.noCitiesInFavorites = false

        }
        else if sender === self {
            mapViewController.title = "Select one City"
            mapViewController.noCitiesInFavorites = true

        }
    }
    
    //this willbe loaded from a storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        //load any saved meals, otherwise load sample data
        if let savedCities = loadCities() {
            
            if savedCities.count > 0 {
                 cities+=savedCities
 
            }

        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if firstLaunch == true {
        
            if let savedCities = loadCities() {
            
                if savedCities.count == 0 {
                
                    self.performSegueWithIdentifier("mapSegue", sender: self)
                }
            }
        }
        firstLaunch = false

    }
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //tableview is not ready at viewdidload
        
        //if there is at least one city saved each time the table appears we mark the last cell the user selected
        if self.cities.first != nil{
            //the first row is the last city selected as in cellForRowAtIndexPath we configure the selected cell to go on top
            currentSelectedIndexPath = NSIndexPath(forRow: 0, inSection: 0)
            tableView.selectRowAtIndexPath(currentSelectedIndexPath, animated: true, scrollPosition: .Top)
           
            //let firstSelectedCell = tableView.cellForRowAtIndexPath(currentSelectedIndexPath!)! as UITableViewCell
            //firstSelectedCell.backgroundColor = UIColor.blueColor()
        }
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // editbutton in the navigation bar for deleting
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        

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
        
        //this will make the scroll begin in the top
        //tableView.setContentOffset(CGPointZero, animated: true)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCity = self.cities[indexPath.row]
        
        //move selected cell to the top, and selected city as first element of cities
        tableView.moveRowAtIndexPath(indexPath, toIndexPath: NSIndexPath(forRow: 0, inSection: 0))
        
        tableView.selectRowAtIndexPath(currentSelectedIndexPath, animated: true, scrollPosition: .Top)
        
        self.cities.removeAtIndex(indexPath.row)
        self.cities.insert(selectedCity, atIndex: 0)
        
        saveCities()
        
        self.delegate?.citySelected(selectedCity)
        
        self.presentDetailViewControllerWithSelectedCity()
        
       

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
            
            //if the user removes the selected city, the first city
            if indexPath.row == 0 {
                if cities.count > 0 {
                    //if there are still cities, launch detail view with the new first city
                    let newSelectedCity = self.cities[indexPath.row]
                    self.delegate?.citySelected(newSelectedCity)
                    self.presentDetailViewControllerWithSelectedCity()
                }
                else {
                    //if user removed all the cities, launch map to let user select another city
                    self.performSegueWithIdentifier("mapSegue", sender: self)
                }
            }
            
            //save cities in MEM
            saveCities()
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

  
    
    //MARK: NSCoding
    func saveCities() {
        let isSuccesfulSave = NSKeyedArchiver.archiveRootObject(cities, toFile: City.ArchiveURL.path!)
        if !isSuccesfulSave { print("Failed to save cities....") }
    }
    
    func loadCities() -> [City]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(City.ArchiveURL.path!) as? [City]
    }

    
}

extension TableViewController: CityAdditionDelegate{
    func cityAddition(newCity: City) {
        
        self.city = newCity
    }
}



