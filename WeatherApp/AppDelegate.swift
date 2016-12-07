//
//  AppDelegate.swift
//  WeatherApp
//
//  Created by Nerea Gonzalez Vazquez on 15/11/16.
//  Copyright © 2016 Nerea Gonzalez Vazquez. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate{

    var window: UIWindow?
    
    //MARK: UIAplicationDelegate
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let leftNavController = splitViewController.viewControllers.first as! UINavigationController
        let tableViewController = leftNavController.topViewController as! TableViewController
        let detailNavViewController = splitViewController.viewControllers.last as! UINavigationController
        let detailViewController = detailNavViewController.topViewController as! DetailViewController
        
        //delegates
        tableViewController.delegate = detailViewController
        splitViewController.delegate = self
        
        //make the detail view after launching corresond to the first city weather
        let firstCity = tableViewController.cities.first
        if firstCity != nil {
            detailViewController.city = firstCity
        }
        
        //nav back button for detail view controller
        detailViewController.navigationItem.leftItemsSupplementBackButton = true
        detailViewController.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()
        
        return true
    }

    
    //MARK: UISplitViewControllerDelegate
    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController, ontoPrimaryViewController primaryViewController: UIViewController) -> Bool {
        
        //Configure the master view controller as primary view controller only if there is no cities, so there is no city to show in the detail view
        guard let secondaryAsNavController = secondaryViewController as? UINavigationController else {
            return false
        }
        guard let topAsDetailController = secondaryAsNavController.topViewController as? DetailViewController else{
            return false
        }
        if topAsDetailController.city == nil {
            return true
        }
        return false
    }
        
    
}

