//
//  MapModel.swift
//  UCSCBus
//
// Developed by
// Radomyr Bezghin
// Nathan Lakritz
// Brian Thyfault
// Rizzian Ciprian Tuazon
// Copyright © 2020 BusTrackerTeam. All rights reserved.

import Foundation
import UIKit

class MapModel {
    private(set) var busArray: [Bus] = []{
        didSet{
            busCount = busArray.count
            //print("Bus count is \(busCount)")
        }
    }
    private(set) var busCount = 0
    
    func checkConnectivity()->Bool{
        return busCount != 0
    }
    func updateBusArray(newBus: Bus){
        for index in 0..<busCount{
            if busArray[index] == newBus{
                //print("Updating existing Bus")
                //print("Old value: \(busArray[index])")
                busArray[index].updateCoordinate(newCoordinate: newBus.coordinate)
                //print("New value: \(busArray[index])")
                return
            }
        }
        //print("Adding new Bus")
        busArray.append(newBus)
    }
}
