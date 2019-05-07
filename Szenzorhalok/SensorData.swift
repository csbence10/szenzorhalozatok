//
//  SensorData.swift
//  Szenzorhalok
//
//  Created by Csondor Bence on 2019. 04. 27..
//  Copyright © 2019. Csondor Bence. All rights reserved.
//

import Foundation

struct SensorData: Codable {
    var busy: Bool
    var label: String
    var coordinates: Coordinates
}

struct Coordinates: Codable {
    var latitude: Double
    var longitude: Double
}
