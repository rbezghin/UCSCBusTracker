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
    //let urlString = "https://www.kerryveenstra.com/location/get/v1/"
    let urlString = "https://ucsc-bts3.soe.ucsc.edu/bus_table.php"
                   //https://ucsc-bts3.soe.ucsc.edu/bus_table.php
    
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

        mapView = MGLMapView(frame: view.frame, styleURL: URL(string: "mapbox://styles/brianthyfault/ck5wvxti30efg1ikv39wd08kv"))
        mapView.delegate = self
        mapView.showsUserLocation = true
        view.addSubview(mapView)   
    }
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        mapView.setCenter((mapView.userLocation?.coordinate)!, zoomLevel: 14, animated: false)

    }
    //add bus tracking here
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        guard let url = URL(string: urlString) else {return}
        
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.performTask(withSession: session, withURL: url) { [weak self] (features) in
                self?.updateBusLocationFeatures(features: features)
            }
        }
      
        // Read and process CSV file contents
        var data = readDataFromCSV(fileName: "bus_stop_data", fileType: ".csv")
        data = cleanRows(file: data!)
        let csvRows = csv(data: data!)
        
        // Initialize annotated points and store into array
        var stops = [MGLPointAnnotation]()
        for _ in 0...csvRows.count-2 {
            let stop = MGLPointAnnotation()
            stops.append(stop)
        }
        
        // Define annotated points using bus stop names and coordinates from CSV file
        for item in 0...csvRows.count-2 {
            stops[item].coordinate = CLLocationCoordinate2D(latitude: Double(csvRows[item][1])!, longitude: Double(csvRows[item][2])!)
            stops[item].title = csvRows[item][0]
            mapView.addAnnotation(stops[item])
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
        //print("Parsing Data")
        var features = featuresToDisplay
        do{
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonArray = jsonData as? [String: Any] else{
                print("JsonSerialization Failed")
                return features}
            //print(jsonArray)
            if let busTableRows = jsonArray["rows"] as? NSArray{
                //print(busTableRows)
                for busData in busTableRows{
                    
                    if let busDictionary = busData as? NSDictionary{
                        //print(busDictionary)
                        let lonString = busDictionary["lon"] as! String
                        let latString = busDictionary["lat"] as! String
                        let lon = Double(lonString)!
                        let lat = Double(latString)!
                        
                        
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        let title = busDictionary["type"] as! String
                        let id = busDictionary["id"] as! String
                        coordinates.append(coordinate)
                        let feature = MGLPointFeature()
                        feature.coordinate = coordinate
                        feature.identifier = id
                        feature.attributes = ["name": title]
                        //check if this feature is in the features and replace by a new one
                        updateFeatures(newFeature: feature)
                        //features.append(feature)
                    }
                }
               
            }
            
//            for item in jsonArray{
//                print(item)
//                let coordinate = CLLocationCoordinate2D(latitude: item["lat"] as! Double, longitude: item["lon"] as! Double)
//                let title = item["type"] as! String
//                let id = item["id"] as! String
//                print("Coordinate is \(coordinate)")
//                coordinates.append(coordinate)
//                let feature = MGLPointFeature()
//                feature.coordinate = coordinate
//                feature.identifier = id
//                feature.attributes = ["name": title]
//                //check if this feature is in the features and replace by a new one
//                updateFeatures(newFeature: feature)
//                features.append(feature)
//            }
        }catch let error {
            print(error.localizedDescription)
        }
        return features
    }
    
    func csv(data: String) -> [[String]] {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }
    
    func readDataFromCSV(fileName:String, fileType: String)-> String!{
            guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
                else {
                    return nil
            }
            do {
                var contents = try String(contentsOfFile: filepath, encoding: .utf8)
                contents = cleanRows(file: contents)
                return contents
            } catch {
                return nil
            }
        }

    func cleanRows(file:String)->String{
        var cleanFile = file
        cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
        cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
        return cleanFile
    }
  
    func updateFeatures(newFeature: MGLPointFeature){
        //check if  feature is in features
        for feature in featuresToDisplay{
            if feature.identifier as! String == newFeature.identifier as! String{
                //print("Updating existing feature")
                feature.coordinate = newFeature.coordinate
                return
            }
        }
        //if not add it
        //print("Adding new feature")
        featuresToDisplay.append(newFeature)
    }
        
    let csvToDatabase: Dictionary = ["Campus Entrance (Main)":"Main Entrance","Lower Campus (Outer)":"Lower Campus","Village and the Farm (Outer)":"Village/Farm",
                             "East Remote Lot Interior":"East Remote Interior","East Remote Parking (Outer)":"East Remote","East Field House":"East Field House",
                             "Cowell & Stevenson (Outer)":"Bookstore","Crown & Merrill":"Crown/Merrill","College 9 & 10 (Outer)":"Colleges 9&10/Health Center",
                             "Science Hill (Outer)":"Science Hill","Kresge (Outer)":"Kresge","Rachel Carson & Porter (Outer)":"Porter/Rachel Carson",
                             "Family Student Housing":"Family Student Housing","Oakes (Outer)":"Oakes/Family Student Housing","Arboretum (Outer)":"Arboretum",
                             "High and Western (Outer)":"Western Drive","Lower Campus (Inner)":"Lower Campus","Village and the Farm (Inner)":"Village/Farm",
                             "East Remote Parking (Inner)":"East Remote","Cowell & Stevenson (Inner)":"Cowell College/Bookstore",
                             "College 9 & 10 (Inner)":"Colleges 9&10/Health Center","Science Hill (Inner)":"Science Hill","Kresge (Inner)":"Kresge",
                             "Kerr Hall Bridge":"Kerr Hall","Rachel Carson & Porter (Inner)":"Porter/Rachel Carson",
                             "Oakes (Inner)":"Oakes/Rachel Carson","West Remote Lot Interior":"West Remote Interior","Arboretum (Inner)":"Arboretum",
                             "High and Western (Inner)":"Western Drive","Campus Entrance (Barn Theater)":"Barn Theatre",]
    
    let innerStops = ["Lower Campus (Inner)","Village and the Farm (Inner)","East Remote Parking (Inner)",
                      "Cowell & Stevenson (Inner)","College 9 & 10 (Inner)","Science Hill (Inner)","Kresge (Inner)",
                      "Kerr Hall Bridge","Rachel Carson & Porter (Inner)","Oakes (Inner)","West Remote Lot Interior",
                      "Arboretum (Inner)","High and Western (Inner)","Campus Entrance (Barn Theater)"]
        
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        var etas = [String]()
        var noETA = false
        
        // Setting up HTTP POST request
        let headers = [
          "content-type": "application/x-www-form-urlencoded",
          "cache-control": "no-cache",
          "postman-token": "23cb4108-e24b-adab-b979-e37fd8f78622"
        ]
        let name = csvToDatabase[annotation.title!!] ?? "" // use database name for request
        let stopString = "bus_stop=" + name
        var location = "outer_eta"
        for stop in innerStops {
            if annotation.title!! == stop {
                location = "inner_eta"
            }
        }
        let urlString = "https://ucsc-bts3.soe.ucsc.edu/bus_stops/" + location + ".php"
        let postData = NSMutableData(data: stopString.data(using: String.Encoding.utf8)!)
        var request = URLRequest(url: URL(string: urlString)! as URL,
                                          cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        print(stopString)
        print(urlString)

        // Sending HTTP POST request and processing response
        let group = DispatchGroup()
        group.enter()
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            }
            DispatchQueue.main.async {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data!)
                    guard let jsonArray = jsonObject as? [String: Any] else{
                        print("JsonSerialization Failed")
                        return
                        }
                    if let etaTableRows = jsonArray["rows"] as? NSArray{
                        for etaData in etaTableRows{
                            let etaDictionary = etaData as? NSDictionary
                            let busType = etaDictionary!["bus_type"] as! String
                            let timeAway = String(etaDictionary!["time_away"] as! Int)
                            let etaCell = busType + " is " + timeAway + " minutes away"
                            etas.append(etaCell)
                        }
                    }
                } catch {
                    print("JSONSerialization error:", error)
                    noETA = true
                }
                 group.leave()
            }
        })
        dataTask.resume()
        group.notify(queue: .main) { // Wait for HTTP section to complete before adding data to table
            mapView.deselectAnnotation(annotation, animated: false)
            let schedule = ScheduleVC()
            schedule.data.append(annotation.title!! + " ETAs:")
            for item in etas {
                schedule.data.append(item)
            }
            if noETA == true {
                schedule.data.append("Sorry, ETAs not available!")
            }
            schedule.data.append("") // two line buffer
            schedule.data.append("")
            self.present(schedule, animated: true, completion: nil)
        }
    }

    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor     annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .detailDisclosure)
    }

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
            return true
        }
    
    func updateBusLocationFeatures(features: [MGLPointFeature]){
        //print("Adding points")
        //print(featuresToDisplay)
        //TODO: dissapearing busses issue
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
        guard  let image = UIImage(named: "bus_stop") else {return nil}
        //resizing image
        let size = CGSize(width: 20, height: 20)
        var newImage: UIImage
        let renderer = UIGraphicsImageRenderer(size: size)
        newImage = renderer.image { (context) in
             image.draw(in: CGRect(origin: .zero, size: size))
        }
        let annotationImage = MGLAnnotationImage(image: newImage, reuseIdentifier: "stop_icon")
        return annotationImage
    }

}

