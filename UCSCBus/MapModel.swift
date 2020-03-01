//
//  MapModel.swift
//  UCSCBus
//
//  Created by Radomyr Bezghin on 2/24/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//

import Foundation

class MapModel {
    var busArray: [Bus] = []{
        didSet{
            busCount = busArray.count
            //print("Bus count is \(busCount)")
        }
    }
    var busCount = 0
    
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
        print("Adding new Bus")
        busArray.append(newBus)
    }
}
