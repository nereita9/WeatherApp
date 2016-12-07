//
//  DetailViewController.swift
//  WeatherApp
//
//  Created by Nerea Gonzalez Vazquez on 15/11/16.
//  Copyright © 2016 Nerea Gonzalez Vazquez. All rights reserved.
//

import UIKit
import SystemConfiguration

class DetailViewController: UIViewController, OpenWeatherMapDelegate{
   
    //MARK: Properties

    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var locationImageView: UIImageView!
    
    @IBOutlet weak var humidityImageView: UIImageView!
    
    @IBOutlet weak var windImageView: UIImageView!
    //MARK: Constraints
    @IBOutlet weak var locationImageViewHeight: NSLayoutConstraint!
    

    
    var timer = NSTimer()
    
    var weather: OpenWeatherMap!
    var initDelegate = true
    var picName: String?
    var tempLabelFontSize: CGFloat?
    
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
    
    func applicationWillResignActive(notification: NSNotification) {
        self.timer.invalidate() //to pause timer
    }
    
    func applicationDidBecomeActive(notification: NSNotification) {
        //to start timer again
        //timer for the time
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(tick), userInfo: nil, repeats: true)

        if self.city != nil {
            self.refreshUI()
        }
        //print("refreshing after passing from background to active")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //timer for the time
        self.tick()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        
        
        
        //when Favorites is empty in ipad landscape detail view is shown a little before launching maps, better see white screen that the default labels..
        
        
        
        self.locationImageView.image = self.locationImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
        self.locationImageView?.tintColor = UIColor.whiteColor()
        
        self.humidityImageView.image = self.humidityImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
        self.humidityImageView?.tintColor = UIColor.whiteColor()
  
        self.windImageView.image = self.windImageView.image!.imageWithRenderingMode(.AlwaysTemplate)
        self.windImageView?.tintColor = UIColor.whiteColor()


        
        self.nameLabel?.text = nil
        self.timeLabel?.text = nil
        self.currentTemperatureLabel?.text = nil
        self.humidityLabel?.text = nil
        self.windLabel?.text = nil
        self.temperatureLabel?.text = nil
        self.weatherLabel?.text = nil
        self.dateLabel?.text = nil
        
        //observe when the application opens from background
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: #selector(self.applicationDidBecomeActive(_:)), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        //observe when the application will go to background       
        NSNotificationCenter.defaultCenter().addObserver(
        self, selector: #selector(self.applicationWillResignActive(_:)), name: UIApplicationWillResignActiveNotification, object: nil)
        
        self.setupFontSizeAndSomeConstraintsDependingOnScale()
        tempLabelFontSize = self.temperatureLabel.font.pointSize
        
       
    }
    
    
    
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        //iphone in portrait
        if size.height > size.width && UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            
            print("\(picName!)_iPhonePortrait.png")
            self.iconImageView?.image = UIImage(named: "\(picName!)_iPhonePortrait.png")
            self.iconImageView?.image = self.iconImageView?.image!.imageWithRenderingMode(.AlwaysTemplate)
            self.iconImageView?.tintColor = UIColor.whiteColor()
        }
        
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
        
        self.picName = city.weatherPicName!
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.nameLabel?.text = city.name.uppercaseString //more style
            self.currentTemperatureLabel?.text = String(city.currentTemperature!)+"ºC"
            self.humidityLabel?.text = String(city.humidity!)+" %"
            self.windLabel?.text = String(city.wind!)+" m/s"
            
            let maxTemp = String(city.maxTemp!)+"º"
            let totalTemp = maxTemp+" / "+String(city.minTemp!)+"ºC"
            let maxTempRange = (totalTemp as NSString).rangeOfString(maxTemp)
            
           
            
            let attributedString = NSMutableAttributedString(string: totalTemp, attributes: [NSFontAttributeName: UIFont(name: "GillSans-SemiBold", size: self.tempLabelFontSize!)!])
            attributedString.setAttributes([NSFontAttributeName: UIFont(name: "GillSans-SemiBold", size: self.tempLabelFontSize!+6)!], range: maxTempRange)
            self.temperatureLabel?.attributedText = attributedString
            
            //self.weatherLabel?.text = city.weather!.capitalizedString
            self.weatherLabel?.text = "Heavy Shower Rain and Drizzle"
            if self.traitCollection.horizontalSizeClass == .Compact && self.traitCollection.verticalSizeClass != .Compact {
                
                self.iconImageView?.image = UIImage(named: "\(city.weatherPicName!)_iPhonePortrait.png")!
            }
            else {
                self.iconImageView?.image = city.weatherPic!
                
            }
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
            let msg: String
            if self.userConnectedToNetwork() == true {
                msg = "The weather service isn't responding."
            }
            else {
                msg = "Your Smartphone is not connected to the Internet! Go to Settings -> Mobile Data to activate it."
            }
            let alertVC = UIAlertController(title: "Can't get the weather", message: msg, preferredStyle: .Alert)
            
            
            let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            
            alertVC.addAction(okAction)
            
            self.presentViewController(alertVC, animated: true, completion: nil)

            
            
        }
       
    }
    
    func alertControllerBackgroundTapped() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tick(){
        let dateTime = NSDate()
        
        
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "HH" //the hour representation with two digits.
        let hour = dateFormatter.stringFromDate(dateTime)
        
        dateFormatter.dateFormat = "mm" //the minutes representation with two digits
        let minute = dateFormatter.stringFromDate(dateTime)
        
        dateFormatter.dateFormat = "EEEE" //the full name of a day
        let weekDay = dateFormatter.stringFromDate(dateTime)

        
        dateFormatter.dateFormat = "dd" //the day number in month with two digits.       
        let day = dateFormatter.stringFromDate(dateTime)

        
        dateFormatter.dateFormat = "MMMM" //the full name of the mont
        let month = dateFormatter.stringFromDate(dateTime)

        dateFormatter.dateFormat = "yyyy" //the year with four digits
        let year = dateFormatter.stringFromDate(dateTime)

        
        self.timeLabel.text = "\(hour):\(minute)"
        self.dateLabel.text = "\(weekDay) \(day) \(month) \(year)"
        
        
       
    }

    
    //MARK: Network Reachability
    func userConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }

    
    //MARK: fontSize
    func setupFontSizeAndSomeConstraintsDependingOnScale() {
        let nameFontSize: CGFloat
        let timeFontSize: CGFloat
        let currentTFontSize: CGFloat
        let defaultFontSize: CGFloat
        
        let locationImageHeight: CGFloat
   
        
        if UIScreen.mainScreen().scale == 2.0 {
            print("scale 2.0")
            //Retina display
            nameFontSize = 19
            timeFontSize = 15
            defaultFontSize = 14
            currentTFontSize = 32
            
            locationImageHeight = 18
            
 
          
        }
        else if UIScreen.mainScreen().scale == 3.0{
            print("scale 3.0")

            //iphone 6 plus
            nameFontSize = 25
            timeFontSize = 19
            defaultFontSize = 18
            currentTFontSize = 45
            
            locationImageHeight = 25
           
            
        }
        else {
            print("scale 1.0")

            nameFontSize = 32
            timeFontSize = 26
            defaultFontSize = 24
            currentTFontSize = 60
            
            locationImageHeight = 30
           
        }
       
        
        self.nameLabel?.font = nameLabel.font.fontWithSize(nameFontSize)
        self.nameLabel?.minimumScaleFactor = 0.5
        self.nameLabel?.adjustsFontSizeToFitWidth = true
        
        
        self.timeLabel?.font = timeLabel.font.fontWithSize(timeFontSize)
        self.currentTemperatureLabel?.font = currentTemperatureLabel.font.fontWithSize(currentTFontSize)
        self.humidityLabel?.font = humidityLabel.font.fontWithSize(defaultFontSize)
        self.windLabel?.font = windLabel.font.fontWithSize(defaultFontSize)
        self.temperatureLabel?.font = temperatureLabel.font.fontWithSize(defaultFontSize)
        
        self.weatherLabel?.font = weatherLabel.font.fontWithSize(defaultFontSize)
        self.weatherLabel?.minimumScaleFactor = 0.3
        self.weatherLabel?.adjustsFontSizeToFitWidth = true
        
        self.dateLabel?.font = dateLabel.font.fontWithSize(defaultFontSize)
        
        self.locationImageViewHeight.constant = locationImageHeight
        

    }

}


extension DetailViewController: CitySelectionDelegate{
    func citySelected(newCity: City) {
        
        self.city = newCity
    }
}






