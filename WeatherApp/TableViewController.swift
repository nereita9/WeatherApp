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
    
    var currentSelectedIndexPath: NSIndexPath?
    
    var cities = [City]()
    
    weak var delegate: CitySelectionDelegate?
    
    //this willbe loaded from a storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        
        //load any saved meals, otherwise load sample data
        if let savedCities = loadCities() {
            
            if savedCities.count > 0 {
                 cities+=savedCities
            }
           
            else {
                loadMainCity()
            }
            

        }
        else {
            loadSampleCities()
            //mas adelante pondremos que ponga la ciudad mas cercana
        }
    }
    
    func loadSampleCities(){
        
        self.cities.append(City(name:"Paris"))
        self.cities.append(City(name:"Madrid"))
    }

    func loadMainCity(){
        self.cities.append(City(name:"Boulogne-Billancourt"))
    }
    
    override func viewWillAppear(animated: Bool) {
        
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
        
        //this will make the scroll begin in the top
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedCity = self.cities[indexPath.row]
        
        //move selected cell to the top, and selected city as first element of cities
        tableView.moveRowAtIndexPath(indexPath, toIndexPath: NSIndexPath(forRow: 0, inSection: 0) )
        
        self.cities.removeAtIndex(indexPath.row)
        self.cities.insert(selectedCity, atIndex: 0)
        

        
        self.delegate?.citySelected(selectedCity)
        if let detailViewController = self.delegate as? DetailViewController {
            
          

            
            if ( (UIDevice.currentDevice().userInterfaceIdiom == .Pad) || (UIDevice.currentDevice().userInterfaceIdiom == .Phone && UIScreen.mainScreen().nativeBounds.height == 2208 ) ){
                
                
                //&& (UIDevice.currentDevice().orientation == .LandscapeLeft || UIDevice.currentDevice().orientation == .LandscapeRight)
                
               // print("ipad or iphone 6 plus")
                
                splitViewController?.showDetailViewController(detailViewController.navigationController!,sender: nil)
                
                
                //hide master view (table view) when clicking. In ipad portrait
                if ( (UIDevice.currentDevice().userInterfaceIdiom == .Pad) && (UIDevice.currentDevice().orientation == .Portrait || UIDevice.currentDevice().orientation == .PortraitUpsideDown)){
                    
                    
                    
                    UIView.animateWithDuration(0.3, animations: {
                        self.splitViewController?.preferredDisplayMode = .PrimaryHidden
                    }, completion: { finished in
                        //restore
                        self.splitViewController?.preferredDisplayMode = .Automatic
                    })
                    
                    
                    


                }
                
                
            }
            else {
                //MARK:super important
                //show the detailviewcontroller nstead of the navigation controller to avoid the size classes variation probles
                //print("iphone")
                splitViewController?.showDetailViewController(detailViewController, sender: nil)
            }
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
