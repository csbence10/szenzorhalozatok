//
//  SensorAnnotation.swift
//  Szenzorhalok
//
//  Created by Csondor Bence on 2019. 04. 27..
//  Copyright © 2019. Csondor Bence. All rights reserved.
//

import Foundation
import MapKit

class SensorAnnotation: NSObject, MKAnnotation {
    
    let title: String?
    let coordinate: CLLocationCoordinate2D
    let subtitle: String?
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        
        super.init()
    }
    
}
