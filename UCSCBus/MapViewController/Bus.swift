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
    var busImageName: String
    // TODO:  (Radomyr) may need to calibrate this
    //used in func busDidntMove TODO
    let negligibleChange = 0.00001

    init(id: Int, busType: String, coordinate: CLLocationCoordinate2D) {
        self.id = id
        self.busType = busType
        self.coordinate = coordinate
        self.sourceIdentifier = "sourceIdentifier_"+String(id)
        self.busLayerIdentifier = "busLayerIdentifier_"+String(id)
        self.busImageName = "busImageName_"+String(id)

    }
    func getBusFeature() -> MGLPointFeature {
        let feature = MGLPointFeature()
        feature.coordinate = coordinate
        feature.identifier = id
        feature.attributes = ["name": busType]
        //print("SendingFeateure: \n Old coordinate - \(oldCoordinate)\n New coordinate - \(coordinate) \n Bearing is \(getBearing())")
        return feature
    }
    mutating func updateCoordinate(newCoordinate: CLLocationCoordinate2D){
        oldCoordinate = coordinate
        coordinate = newCoordinate
    }
    
    //get how many degrees icon needs to be rotated
    func getBearing() -> Double {
        if(busDidntMove()){
            return 0 //dont rotate
        }
        let x1 = oldCoordinate.longitude * (Double.pi / 180.0)
        let y1 = oldCoordinate.latitude  * (Double.pi / 180.0)
        let x2 = coordinate.longitude   * (Double.pi / 180.0)
        let y2 = coordinate.latitude    * (Double.pi / 180.0)
        let dx = x2 - x1
        let sita = atan2(sin(dx) * cos(y2), cos(y1) * sin(y2) - sin(y1) * cos(y2) * cos(dx))
        return ((sita * (180.0 / Double.pi)))
    }
    
    // need to check how much bus moved to avoid unneccessary rotation when bus is at the same spot
    func busDidntMove()-> Bool{
        if(coordinate.latitude == oldCoordinate.latitude && coordinate.longitude == oldCoordinate.longitude){
            return true
        }
        let dy = abs(coordinate.latitude - oldCoordinate.latitude)
        let dx = abs(coordinate.longitude - oldCoordinate.longitude)
        if (dy < negligibleChange && dx < negligibleChange){
            return true
        }
        return false
    }
}


//
//{
//    basestation = OPERS;
//    id = 93;
//    lat = "36.99150167";
//    lon = "-122.05488833";
//    "time_stamp" = "2020-04-08 16:37:50";
//    type = LOOP;
//}
//{
//    basestation = OPERS;
//    id = 93;
//    lat = "36.99211";
//    lon = "-122.05517333";
//    "time_stamp" = "2020-04-08 16:37:56";
//    type = LOOP;
//
//  36.99150167 - 36.99211 =  -0.00060833
//  -122.05488833 + 122.05517333 = 0.000285
//}
