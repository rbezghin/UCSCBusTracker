//
//  ViewController.swift
//  UCSCBus
//
//  Created by Radomyr Bezghin on 1/27/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//

import Mapbox
import Foundation
//import MapboxCoreNavigation
//import MapboxNavigation
//import MapboxDirections

class ViewController: UIViewController, MGLMapViewDelegate {
    
    var mapView: MGLMapView!
    var source: MGLSource!
    var timer: Timer!

    override func viewDidLoad() {
        super.viewDidLoad()
        //mapView = MGLMapView(frame: view.frame)
        mapView = MGLMapView(frame: view.frame, styleURL: URL(string: "mapbox://styles/brianthyfault/ck5wvxti30efg1ikv39wd08kv"))
        mapView.delegate = self
        mapView.setCenter(CLLocationCoordinate2D(latitude: 36.99, longitude: -122.05), zoomLevel: 12, animated: false)
        view.addSubview(mapView)
        receiveDataFromDB()
        
    }
    
    //
    func receiveDataFromDB(){
        if let url = URL(string: "https://www.kerryveenstra.com/location/get/v1/"){
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                //data was successfully received and can be parsed
                guard let data = data else{return}
                self.parseDataFromDB(data: data)
            }
            task.resume()
        }
    }
    
    //processing data received from database
    func parseDataFromDB(data: Data){
        do{
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonArray = jsonData as? [[String: Any]] else{return}
            //At this point data is safely converted to an array of busses + their location
            print(jsonArray)
        }catch let error {
            print(error.localizedDescription)
        }
    }

    
    //add traking data here
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
        // create a source of data
        var coordinates = CLLocationCoordinate2D(latitude: 36.99, longitude: -122.05)
        let point = MGLPolygonFeature(coordinates: &coordinates, count: 1)
        let source = MGLShapeSource(identifier: "bus", shape: point, options: nil)
        mapView.style?.addSource(source)
        // add it to MGLstyle
        
        
        let busLayer = MGLSymbolStyleLayer(identifier: "bus", source: source)
        busLayer.iconImageName = NSExpression(forConstantValue: "bus_icon")
        busLayer.iconHaloColor = NSExpression(forConstantValue: UIColor.white)
        style.addLayer(busLayer)
    }
    
    //stop timer if view dissapeared
    override func viewWillDisappear(_ animated: Bool) {
        
    }


}

