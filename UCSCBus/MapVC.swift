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

class MapVC: UIViewController, MGLMapViewDelegate {
    
    var mapView: MGLMapView!
    var source: MGLSource!
    var timer: Timer!
    var busArray: [BusModel]!
    var coordinates = [CLLocationCoordinate2D]()
    

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

    
    //add bus traking  here
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
        coordinates = [CLLocationCoordinate2D(latitude: 36.99, longitude: -122.05), CLLocationCoordinate2D(latitude: 36.99, longitude: -121.05)]
        var pointAnnotations = [MGLPointAnnotation]()
        for coordinate in coordinates {
            let point = MGLPointAnnotation()
            point.coordinate = coordinate
            point.title = "\(coordinate.latitude), \(coordinate.longitude)"
            pointAnnotations.append(point)
        }
        mapView.addAnnotations(pointAnnotations)

    }
    
    //adds an image to bus points
    //TODO: resize image
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        guard  let image = UIImage(named: "bus_icon") else {return nil}
        //resizing image
        let size = CGSize(width: 20, height: 20)
        var newImage: UIImage
        let renderer = UIGraphicsImageRenderer(size: size)
        newImage = renderer.image { (context) in
             image.draw(in: CGRect(origin: .zero, size: size))
        }
        let annotationImage = MGLAnnotationImage(image: newImage, reuseIdentifier: "bus_icon")
        return annotationImage
    }
    
    //not needed rn kek
    func createGeoJSON(id: Int, busType: String, latitude: Float, longitude: Float) -> [String : Any] {
        let geoJson = [
        "type" : "FeatureCollection",
        "features" :
            [
                [
                    "type" : "Feature",
                    "geometry" : [
                        "type": "Point",
                        "coordinates": [36.99, -122.05]
                    ],
                    "properties" : [
                        "name" : "\(busType)"
                    ]
                ]
            ]
        ] as [String : Any]
        return geoJson
    }
    
    //stop timer if view dissapeared
    override func viewWillDisappear(_ animated: Bool) {
        
    }


}

