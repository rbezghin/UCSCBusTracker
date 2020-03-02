//
//  MapModel.swift
//  UCSCBus
//
//  Created by Radomyr Bezghin on 2/24/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//

import Foundation
import UIKit

class MapModel {
    private(set) var busArray: [Bus] = []{
        didSet{
            busCount = busArray.count
            //print("Bus count is \(busCount)")
        }
    }
    private let busIconName = "bus_top_shuttle_icon"
    private(set) lazy var busImage: UIImage = {
        let image = UIImage(named: busIconName)
        let size = CGSize(width: 25, height: 25)
        var newImage: UIImage
        let renderer = UIGraphicsImageRenderer(size: size)
        newImage = renderer.image { (context) in
            image?.draw(in: CGRect(origin: .zero, size: size))
        }
        return newImage
    }()
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
        print("Adding new Bus")
        busArray.append(newBus)
    }
}
