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
    var coordinates = [CLLocationCoordinate2D]() //are used to store locations of features
    var featuresToDisplay = [MGLPointFeature]()
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
        
        //maybe set to current user location
        mapView.setCenter(CLLocationCoordinate2D(latitude: 36.99746, longitude: -122.055105), zoomLevel: 13, animated: false)
        view.addSubview(mapView)
    }
    //add bus traking  here
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        guard let url = URL(string: urlString) else {return}
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.performTask(withSession: session, withURL: url) { [weak self] (features) in
                self?.updateBusLocationFeatures(features: features)
            }
        }
    }
    //
    func performTask(withSession: URLSession, withURL: URL,completion: @escaping (([MGLPointFeature]) -> Void)){
        let task = withSession.dataTask(with: withURL) { (data, response, error) in
            if error != nil {
                print( "Error in task \(String(describing: error)) ")
                return
            }
            guard let data = data else{return}
                            //data was successfully received and can be parsed
            DispatchQueue.main.async {
                completion(self.parseDataFromDB(data: data))
            }
        }
        task.resume()
    }
    //processing data received from database
    func parseDataFromDB(data: Data)->[MGLPointFeature]{
        print("Parsing Data")
        var features = featuresToDisplay
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
                feature.identifier = id
                feature.attributes = ["name": title]
                //check if this feature is in the features and replace by a new one
                updateFeatures(newFeature: feature)
                features.append(feature)
            }
        }catch let error {
            print(error.localizedDescription)
        }
        return features
    }
    func updateFeatures(newFeature: MGLPointFeature){
        //check if  feature is in features
        for feature in featuresToDisplay{
            if feature.identifier as! String == newFeature.identifier as! String{
                feature.coordinate = newFeature.coordinate
                return
            }
        }
        //if not add it
        featuresToDisplay.append(newFeature)
    }

    func updateBusLocationFeatures(features: [MGLPointFeature]){
        print("Adding points")
        print(featuresToDisplay)
        //FIXING dissapearing busses issue
        let source: MGLShapeSource
        guard let style = mapView.style else { return }
        
        //if there already exist source and layer with busses
        //it must be removed and new one added
        //else create first source
        if let existingSource = style.source(withIdentifier: "bus_source") {
            //get existing source
            //convert features into shapes and add them to the existing source
            let shapeSource = existingSource as! MGLShapeSource
            let collection = MGLShapeCollectionFeature(shapes: featuresToDisplay)
            shapeSource.shape = collection
        }
        else{
            //new source
            source = MGLShapeSource(identifier: "bus_source", features: features, options: nil)
            style.addSource(source)
            let color = UIColor(red: 0.08, green: 0.44, blue: 0.96, alpha: 1.0)
            let circles = MGLCircleStyleLayer(identifier: "circles", source: source)
            circles.circleColor = NSExpression(forConstantValue: color)

            // The circles should increase in opacity from 0.5 to 1 based on zoom level.
            circles.circleOpacity = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)", [2: 0.5, 7: 1])
            circles.circleRadius = NSExpression(format: "mgl_step:from:stops:($zoomLevel, 1, %@)", [2: 3, 7: 4 ])
            style.addLayer(circles)

        }
            //CUSTOM BUS ICON
//           style.setImage(busIconImage, forName: "bus_image")
//            let source = MGLShapeSource(identifier: "bus_source", features: features, options: nil)
//            style.addSource(source)
            
    //         CUSTOM BUS ICON
    //        let busLayer = MGLSymbolStyleLayer(identifier: "bus_layer", source: source)
    //        busLayer.iconImageName = NSExpression(forConstantValue: "bus_image")
    //        style.addLayer(busLayer)

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

