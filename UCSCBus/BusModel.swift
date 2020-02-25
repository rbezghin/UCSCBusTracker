//
//  Bus.swift
//  UCSCBus
//
//  Created by Radomyr Bezghin on 1/31/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//

import Mapbox
import Foundation

struct BusModel {
    var id: Int
    var busType: String
    var latitude: Double
    var longitude: Double
    var sourceIdentifier: String
    var busLayerIdentifier: String
    var busUIImage: UIImage
    var busImageName: String

    init(id: Int, busType: String, latitude: Double, longitude: Double) {
        self.id = id
        self.busType = busType
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func getBusCoordinate() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
}
