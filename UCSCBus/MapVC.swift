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
    
    var Map = MapModel()
    var mapView: MGLMapView!
    let urlString = "https://ucsc-bts3.soe.ucsc.edu/bus_table.php"
    let busIconImageName = "bus_top_shuttle_icon"
    let mapBoxStyleURLString = "mapbox://styles/brianthyfault/ck5wvxti30efg1ikv39wd08kv"
    
    lazy var busIconImage: UIImage = {
        let image = UIImage(named: busIconImageName)
        let size = CGSize(width: 25, height: 25)
        var newImage: UIImage
        let renderer = UIGraphicsImageRenderer(size: size)
        newImage = renderer.image { (context) in
            image?.draw(in: CGRect(origin: .zero, size: size))
        }
        return newImage
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView = MGLMapView(frame: view.frame, styleURL: URL(string: mapBoxStyleURLString))
        mapView.delegate = self
        mapView.showsUserLocation = true
        // Enable the always-on heading indicator for the user location annotation.
        mapView.showsUserHeadingIndicator = true
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
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
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            self.performTask(withSession: session, withURL: url) { [weak self]  in
                self?.updateBusLocationFeatures()
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
    func performTask(withSession: URLSession, withURL: URL,completion: @escaping ((()) -> Void)){
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
    func parseDataFromDB(data: Data){
        do{
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonArray = jsonData as? [String: Any] else{
                print("JsonSerialization Failed")
                return
            }
            if let busTableRows = jsonArray["rows"] as? NSArray{
                for busData in busTableRows{
                    if let busDictionary = busData as? NSDictionary{
                        print(busDictionary)
                        let lonString = busDictionary["lon"] as! String
                        let latString = busDictionary["lat"] as! String
                        let lon = Double(lonString)! ; let lat = Double(latString)!
                        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        let title = busDictionary["type"] as! String
                        let id = Int(busDictionary["id"] as! String)!
                        let bus = Bus(id: id, busType: title,coordinate: coordinate)
                        Map.updateBusArray(newBus: bus)
                    }
                }
            }
        }catch let error {
            print(error.localizedDescription)
        }
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
        
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        // Hide the callout view.
        mapView.deselectAnnotation(annotation, animated: false)
     
        let schedule = ScheduleVC()
        schedule.name = annotation.title!!
        self.present(schedule, animated: true, completion: nil)
        
        
        /* ALERT POPUP VERSION (use in case we can't figure out better option)
         
        if annotation.title == "College 9 & 10 (Outer)" {
            let alert = UIAlertController(title: annotation.title!!, message: "Upper Campus - 5 min\nLoop - 7 min", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if annotation.title == "College 9 & 10 (Inner)" {
            let alert = UIAlertController(title: annotation.title!!, message: "Upper Campus - 3 min\nLoop - 8 min", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        */
    }

    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor     annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .detailDisclosure)
    }

    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
            return true
        }
    
    func updateBusLocationFeatures(){
        //print(featuresToDisplay)
        //print("Bus array before adding to map \(map.busArray)")
        for bus in Map.busArray{
            let feature = bus.getBusFeature()
            guard let style = mapView.style else { return }
            let source: MGLShapeSource
            //if there already exist source and layer with busses it must be removed and new one added
            if let existingSource = style.source(withIdentifier: bus.sourceIdentifier) {
                //convert features into shapes and add them to the existing source
                let shapeSource = existingSource as! MGLShapeSource
                let collection = MGLShapeCollectionFeature(shapes: [feature])
                shapeSource.shape = collection
                let busLayer = style.layer(withIdentifier: bus.busLayerIdentifier) as! MGLSymbolStyleLayer
                let bearing = bus.getBearing()
                if bearing != 0 {
                    busLayer.iconRotation = NSExpression(forConstantValue: (bearing - 90))
                }
                
            }
            else{
                //new source
                source = MGLShapeSource(identifier: bus.sourceIdentifier, features: [feature], options: nil)
                style.addSource(source)
                //CUSTOM BUS ICON
                style.setImage(busIconImage, forName: busIconImageName)
                let busLayer = MGLSymbolStyleLayer(identifier: bus.busLayerIdentifier, source: source)
                busLayer.iconImageName = NSExpression(forConstantValue: bus.busImageName)
                busLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
                busLayer.iconRotation = NSExpression(forConstantValue: 0)
                busLayer.iconOpacity = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",[5.9: 0, 6: 1])
                busLayer.iconScale = NSExpression(format: "mgl_step:from:stops:($zoomLevel, 1, %@)", [14: 1.7, 15: 1.5, 16: 1.4, 18: 1.5, 19: 1.6   ])
                style.addLayer(busLayer)
            }
        }
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

