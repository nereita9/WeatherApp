//
//  ColorPointAnnotation.swift
//  WeatherApp
//
//  Created by Nerea Gonzalez Vazquez on 25/11/16.
//  Copyright © 2016 Nerea Gonzalez Vazquez. All rights reserved.
//

import UIKit
import MapKit

class ColorPointAnnotation: MKPointAnnotation {
    var pinColor: UIColor
    init(pinColor: UIColor) {
        self.pinColor = pinColor
        super.init()
    }
}
