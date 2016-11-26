//
//  TableViewController.swift
//  WeatherApp
//
//  Created by Nerea Gonzalez Vazquez on 15/11/16.
//  Copyright © 2016 Nerea Gonzalez Vazquez. All rights reserved.
//

import UIKit
import CoreLocation


protocol CitySelectionDelegate: class {
    func citySelected(newCity: City)
}

class TableViewController: UITableViewController, CLLocationManagerDelegate {
    
   
    
    var currentSelectedIndexPath: NSIndexPath?
    
    var cities = [City]()
    
    
    var city: City! {
        didSet (newCity){
            
            self.refreshTable()
        }
    }
    
    func refreshTable(){
        
        self.cities.insert(city, atIndex: 0)
        
        tableView.reloadData()
        //save cities in MEM
        saveCities()
    }
    


    
    weak var delegate: CitySelectionDelegate?
    
    let locationManager = CLLocationManager()
    
    var weather: OpenWeatherMap!
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    
    //MARK: Actions
    
    /*@IBAction func showMapView(sender: UIBarButtonItem) {
        mapViewController.delegate = self
        self.navigationController?.pushViewController(mapViewController, animated: true)
    }*/
    
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if sender === addButton {
        
            let mapNavViewController = segue.destinationViewController as! UINavigationController
            let mapViewController = mapNavViewController.topViewController as! MapViewController
            mapViewController.delegate = self
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
            else {
                
                getLocation()
            }
        }
            
        else {
            
            getLocation()
        }
            

        
        
    }
    
    func loadSampleCities(){
        
        self.cities.append(City(name:"Paris"))
        self.cities.append(City(name:"Madrid"))
    }

    func setDefaultCity(){
        //put Paris in case of no location
        self.cities.append(City(name:"Paris"))
        self.delegate?.citySelected(self.cities.first!)
        
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
    
    //MARK: CLLocationManager
    func getLocation() {
        guard CLLocationManager.locationServicesEnabled() else {
            
            let alertVC = UIAlertController(title: "Location services are disabled on your device", message: "In order to use ths app, go to Settings → Privacy → Location Services and turn location services on.", preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertVC.addAction(okAction)
            self.presentViewController(alertVC, animated: true, completion: nil)
            
            //if location failed, setdefault city Paris
            setDefaultCity()
            return
        }
        
        let authStatus = CLLocationManager.authorizationStatus()
        guard authStatus == .AuthorizedWhenInUse else {
            switch authStatus {
            case .Denied, .Restricted:
                
                let alertVC = UIAlertController(title: "This app is not authorized to use your location.", message: "In order to use this app, go to Settings → WeatherApp → Location and select the \"While Using the App\" setting.", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertVC.addAction(okAction)
                self.presentViewController(alertVC, animated: true, completion: nil)
                
            case .NotDetermined:
                locationManager.requestWhenInUseAuthorization()
                
            default:
                print("Oops! This case should never be reached.")
                
            }
            //if location failed, setdefault city Paris
          
            setDefaultCity()
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate methods
    
    // This is called if:
    // - the location manager is updating, and
    // - it was able to get the user's location.
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       
        let location = locations.last!
        print("location")
        saveCityByCoordinates(location)
            
        
      
    }
    
    var notify = true
    // This is called if:
    // - the location manager is updating, and
    // - it WASN'T able to get the user's location.
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        // This method is called asynchronously, which means it won't execute in the main queue.
        // All UI code needs to execute in the main queue, which is why we're wrapping the call
        
        //it enters here several times and problems comes, we want to avoid that
        if notify == true {
        
            dispatch_async(dispatch_get_main_queue()) {
                let alertVC = UIAlertController(title: "Can't determine your location", message: "The GPS and other location services aren't responding.", preferredStyle: .Alert)
                let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertVC.addAction(okAction)
                self.presentViewController(alertVC, animated: true, completion: nil)
        
                //if location failed, setdefault city Paris
                self.setDefaultCity()
                print("set default city")
            }
            notify = false
        }
    }
    
    
    func saveCityByCoordinates(location: CLLocation) {
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placemarks?[0]
            
            
            // City
            if let myCity = placeMark.addressDictionary!["City"] as? NSString {
                print(myCity)
                self.cities.append(City(name: String(myCity)))
                self.delegate?.citySelected(self.cities.first!)
            }
            

           
            
        })

    }

    
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

extension TableViewController: CityAdditionDelegate{
    func cityAddition(newCity: City) {
        
        self.city = newCity
    }
}



