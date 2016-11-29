//
//  ColorPointAnnotation.swift
//  WeatherApp
//
//  Created by Nerea Gonzalez Vazquez on 25/11/16.
//  Copyright © 2016 Nerea Gonzalez Vazquez. All rights reserved.
//  test

import UIKit
import MapKit

class CustomAnnotation: MKPointAnnotation {
    var city: String
    var cityId: Int
    var pinColor: UIColor
    
    init(city: String, cityId: Int, pinColor: UIColor) {
        self.city = city
        self.cityId = cityId
        self.pinColor = pinColor
        super.init()
    }
}
