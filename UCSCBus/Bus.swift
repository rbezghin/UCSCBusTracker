//
//  Bus.swift
//  UCSCBus
//
//  Created by Radomyr Bezghin on 1/31/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//

import Mapbox
import Foundation

struct Bus: Equatable, CustomStringConvertible {
    var description: String {
        return "\(id) lat: \(coordinate.latitude) lon: \(coordinate.longitude)"
    }
    static func == (lhs: Bus, rhs: Bus) -> Bool {
        return lhs.id == rhs.id
    }
    
    private(set) var id: Int
    private(set) var busType: String
    private(set) var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    private(set) var oldCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var sourceIdentifier: String
    var busLayerIdentifier: String
    var busUIImage: UIImage?
    var busImageName: String

    init(id: Int, busType: String, latitude: Double, longitude: Double) {
        self.id = id
        self.busType = busType
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.sourceIdentifier = "sourceIdentifier_"+String(id)
        self.busLayerIdentifier = "busLayerIdentifier_"+String(id)
        self.busImageName = "busImageName_"+String(id)

    }
    
    func getBusFeature() -> MGLPointFeature {
        let feature = MGLPointFeature()
        feature.coordinate = coordinate
        feature.identifier = id
        feature.attributes = ["name": busType]
        print("SendingFeateure: \n Old coordinate - \(oldCoordinate)\n New coordinate - \(coordinate) \n Bearing is \(getBearing())")
        return feature
    }
    mutating func updateCoordinate(newCoordinate: CLLocationCoordinate2D){
        oldCoordinate = coordinate
        coordinate = newCoordinate
    }
    
    func getBearing() -> Double {
        let x1 = oldCoordinate.longitude * (Double.pi / 180.0)
        let y1 = oldCoordinate.latitude  * (Double.pi / 180.0)
        let x2 = coordinate.longitude   * (Double.pi / 180.0)
        let y2 = coordinate.latitude    * (Double.pi / 180.0)

        let dx = x2 - x1
        let sita = atan2(sin(dx) * cos(y2), cos(y1) * sin(y2) - sin(y1) * cos(y2) * cos(dx))

        return sita * (180.0 / Double.pi) - 100
    }
    func getDirection()-> Double{
        let dy = oldCoordinate.latitude - coordinate.latitude
        let dx = oldCoordinate.longitude - coordinate.longitude
        var rads = atan2(dy, dx)
//        if (rads < 0) {
//            rads += Double.pi*2.0
//        }
        
        return rads * 180 / Double.pi
    }
    
}
