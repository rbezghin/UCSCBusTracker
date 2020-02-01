//
//  Bus.swift
//  UCSCBus
//
//  Created by Radomyr Bezghin on 1/31/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//

import Foundation

struct BusModel {
    var id: Int
    var busType: String
    var latitude: Float
    var longitude: Float
    init(id: Int, busType: String, latitude: Float, longitude: Float) {
        self.id = id
        self.busType = busType
        self.latitude = latitude
        self.longitude = longitude
    }
}
