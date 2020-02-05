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
    let urlString = "https://www.kerryveenstra.com/location/get/v1/"
    let busIconImage: UIImage = {
        let image = UIImage(named: "bus_icon")
        let size = CGSize(width: 20, height: 20)
        var newImage: UIImage
        let renderer = UIGraphicsImageRenderer(size: size)
        newImage = renderer.image { (context) in
            image?.draw(in: CGRect(origin: .zero, size: size))
        }
        return newImage
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
     // longitude -122.055105 latitude 36.99746
        //mapView = MGLMapView(frame: view.frame)
        mapView = MGLMapView(frame: view.frame, styleURL: URL(string: "mapbox://styles/brianthyfault/ck5wvxti30efg1ikv39wd08kv"))
        mapView.delegate = self
        mapView.setCenter(CLLocationCoordinate2D(latitude: 36.99746, longitude: -122.055105), zoomLevel: 12, animated: false)
        view.addSubview(mapView)
    }
    
    //
    func receiveDataFromDB(completion: @escaping (([MGLPointFeature]) -> Void)){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    print( "Error in task \(String(describing: error)) ")
                    return
                }
                //data was successfully received and can be parsed
                guard let data = data else{return}
                DispatchQueue.main.async {
                    completion(self.parseDataFromDB(data: data))
                }
            }
            task.resume()
        }
    }
    
    //processing data received from database
    func parseDataFromDB(data: Data)->[MGLPointFeature]{
        print("Parsing Data")
        var features = [MGLPointFeature]()
        do{
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonArray = jsonData as? [[String: Any]] else{return features}
            //At this point data is safely converted to an array of busses + their location
            print(jsonArray)
            coordinates.removeAll()
            for item in jsonArray{
                let coordinate = CLLocationCoordinate2D(latitude: item["lat"] as! Double, longitude: item["lon"] as! Double)
                let title = item["type"] as! String
                let id = item["id"] as! String
                print("Coordinate is \(coordinate)")
                coordinates.append(coordinate)
                let feature = MGLPointFeature()
                feature.coordinate = coordinate
                //feature.coordinate = CLLocationCoordinate2D(latitude: 36.99, longitude: -122.05)
                feature.identifier = id
                features.append(feature)
                feature.attributes = [
                "name": title
                ]
            }
        }catch let error {
            print(error.localizedDescription)
        }
        return features
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
       receiveDataFromDB() { [weak self] (features) in
           self?.updateAnnotations(features: features)
       }
        
        // Adding bus stops as annotations
        let stop1 = MGLPointAnnotation()
        stop1.coordinate = CLLocationCoordinate2D(latitude: 37.000, longitude: -122.058) // TODO - make more accurate
        stop1.title = "nineten" // TODO - Use official bus stop names
        mapView.addAnnotation(stop1)

        let stop2 = MGLPointAnnotation()
        stop2.coordinate = CLLocationCoordinate2D(latitude: 37.000, longitude: -122.062)
        stop2.title = "baskin"
        mapView.addAnnotation(stop2)
    }
        
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        // Hide the callout view.
        mapView.deselectAnnotation(annotation, animated: false)
     
        // Show an alert containing the bus stop ETA table
        if annotation.title == "nineten" {
            let alert = UIAlertController(title: annotation.title!!, message: "ETAs here", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if annotation.title == "baskin" {
            let alert = UIAlertController(title: annotation.title!!, message: "ETAs here", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor     annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .detailDisclosure)
    }

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
            return true
        }
    
    func updateAnnotations(features: [MGLPointFeature]){
        print("Adding points")
        print(features)
        guard let style = mapView.style else { return }
        style.setImage(busIconImage, forName: "bus_image")
        let source = MGLShapeSource(identifier: "bus_source", features: features, options: nil)
        style.addSource(source)
        
//        let busLayer = MGLSymbolStyleLayer(identifier: "bus_layer", source: source)
//        busLayer.iconImageName = NSExpression(forConstantValue: "bus_image")
//        style.addLayer(busLayer)
        
        let color = UIColor(red: 0.08, green: 0.44, blue: 0.96, alpha: 1.0)
        let circles = MGLCircleStyleLayer(identifier: "circles", source: source)
        circles.circleColor = NSExpression(forConstantValue: color)

        // The circles should increase in opacity from 0.5 to 1 based on zoom level.
        circles.circleOpacity = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", [2: 0.5, 7: 1])
        circles.circleRadius = NSExpression(format: "mgl_step:from:stops:($zoomLevel, 1, %@)", [2: 3, 7: 4 ])
        style.addLayer(circles)

//        let busLayer = MGLSymbolStyleLayer(identifier: "bus_location", source: source)
//        busLayer.iconImageName = NSExpression(forConstantValue: "bus_image")
//        busLayer.iconHaloColor = NSExpression(forConstantValue: UIColor.white)
//       style.addLayer(busLayer)
        

    }
    
    //adds an image to bus points
    //TODO: resize image
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        guard  let image = UIImage(named: "blank_icon") else {return nil}
        //resizing image
        let size = CGSize(width: 20, height: 20)
        var newImage: UIImage
        let renderer = UIGraphicsImageRenderer(size: size)
        newImage = renderer.image { (context) in
             image.draw(in: CGRect(origin: .zero, size: size))
        }
        let annotationImage = MGLAnnotationImage(image: newImage, reuseIdentifier: "blank_icon")
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

