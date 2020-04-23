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

class MapViewController: UIViewController, MGLMapViewDelegate {
    let SizesAndConstants = ConstantSizes()
    var Map = MapModel()
    var mapView: MGLMapView!
    let urlString = "https://ucsc-bts3.soe.ucsc.edu/bus_table.php"
    let mapBoxStyleURLString = "mapbox://styles/brianthyfault/ck7azhx9h083p1hqvwh2409ic"
    
    var userLocationButton: UserLocationUIButton?
    var label: NoBussesAvailableUILabel?
    let durationAndDelay = 0.7
    
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
        setupLocationButton()
        setupBussesNotRunningLabel()
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        if mapView.userLocation?.coordinate.latitude == -180 { // if user doesn't allow their location
            mapView.setCenter(CLLocationCoordinate2D(latitude: 36.988792, longitude: -122.059351), zoomLevel: 13.2, animated: false)
            }
        else {
            mapView.setCenter((mapView.userLocation?.coordinate)!, zoomLevel: 14, animated: false)
        }
    }
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        
        //**********busses info
        //
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
        //**********busstops info
        //
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
            stops[item].subtitle = csvRows[item][3]
            mapView.addAnnotation(stops[item])
        }
    }
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
    //FIXME: (Radomyr) add error checking
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
        //FIXME:  fatal error: Unexpectedly found nil while unwrapping an Optional value: line 180
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
            let schedule = ScheduleTableViewController()
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
    
    func updateBusLocationFeatures(){
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
                style.setImage(Map.busImage, forName: bus.busImageName)
                let busLayer = MGLSymbolStyleLayer(identifier: bus.busLayerIdentifier, source: source)
                busLayer.iconImageName = NSExpression(forConstantValue: bus.busImageName)
                busLayer.iconAllowsOverlap = NSExpression(forConstantValue: true)
                busLayer.iconRotation = NSExpression(forConstantValue: 0)
                busLayer.iconOpacity = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",[5.9: 0, 6: 1])
                busLayer.iconScale = NSExpression(format: "mgl_step:from:stops:($zoomLevel, 1, %@)", [10:1.7, 14: 1.3, 15: 1.4, 16: 1.4, 18: 1.5, 19: 1.6   ])
                style.addLayer(busLayer)
            }
        }
    }
    //adds an image to bus points
    //TODO: resize image
    func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if let image = createImage(withSize: SizesAndConstants.invisibleBusIconSize, withName: SizesAndConstants.busStopImageName){
            let annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: SizesAndConstants.busStopIconReuseIdentifier)
            return annotationImage
        }
        return nil
    }
    // regionDidChangeAnimated to change visibility of bus stop annotations
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        let zoomLevel = mapView.zoomLevel
        if let annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: SizesAndConstants.busStopIconReuseIdentifier){
            if zoomLevel < 16 {
                let image = createImage(withSize: SizesAndConstants.invisibleBusIconSize, withName: SizesAndConstants.busStopImageName)
                if let image = image{
                    annotationImage.image = image
                }
            }
            else{
                let image = createImage(withSize: SizesAndConstants.visibleBusIconSize, withName: SizesAndConstants.busStopImageName)
                if let image = image{
                    annotationImage.image = image
                }
            }
        }
    }
    func createImage(withSize size: CGSize,withName name: String) -> UIImage?{
        guard  let image = UIImage(named: name) else {return nil}
        var newImage: UIImage
        let renderer = UIGraphicsImageRenderer(size: size)
        newImage = renderer.image { (context) in
             image.draw(in: CGRect(origin: .zero, size: size))
        }
        return newImage
    }

        
    func setupBussesNotRunningLabel(){
        //FIXME : Radomyr labels are messed up
        //busses running not running
        label = setupLabelConstraints()
        if let label = label{
            let topAnchorConstaint = label.topAnchor
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { timer in
                if(self.Map.busCount == 0 && label.labelWasDissmissed == false){  // show the no busses running label
                    label.text = label.textOffline
                    label.labelAppear()
                }
                else if(self.Map.busCount != 0){//there is a bus
                    label.backgroundColor = .systemGreen
                    label.text = label.textOnline
                    //label was either dissmissed before, removed from the view or it is still in the view
                    if(label.isHidden == false){
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            label.labelDissappear()
                        }
                        timer.invalidate()
                    }
                    else{
                        label.labelAppear()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            label.labelDissappear()
                        }
                        timer.invalidate()
                    }
                }
                if label.labelWasDissmissed == true {
                    timer.invalidate()
                }
            }
        }

    }
    //FIXME: (Radomyr) constants must be not variable nubmers
    func setupLabelConstraints() -> NoBussesAvailableUILabel{
        let label = NoBussesAvailableUILabel(frame: CGRect(x: 0, y: -50, width: 0, height: 0))
        label.isHidden = true
        view.addSubview(label)
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: label.labelHeight).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -label.labelHeight).isActive = true
        label.heightAnchor.constraint(equalToConstant: label.labelHeight).isActive = true
        return label
    }

    
    func setupLocationButton() {
        userLocationButton = UserLocationUIButton(buttonSize: 45)
        if let userLocationButton = userLocationButton{
            userLocationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
            userLocationButton.tintColor = mapView.tintColor
            userLocationButton.translatesAutoresizingMaskIntoConstraints = false

            var leadingConstraintSecondItem: AnyObject
            if #available(iOS 11.0, *) {
                leadingConstraintSecondItem = view.safeAreaLayoutGuide
            } else {
                leadingConstraintSecondItem = view
            }

            let constraints: [NSLayoutConstraint] = [
                NSLayoutConstraint(item: userLocationButton, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: topLayoutGuide, attribute: .bottom, multiplier: 1, constant: 10),
                NSLayoutConstraint(item: userLocationButton, attribute: .leading, relatedBy: .equal, toItem: leadingConstraintSecondItem, attribute: .leading, multiplier: 1, constant: 10),
                NSLayoutConstraint(item: userLocationButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: userLocationButton.frame.size.height),
                NSLayoutConstraint(item: userLocationButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: userLocationButton.frame.size.width)
            ]

            view.addSubview(userLocationButton)
            view.addConstraints(constraints)
            self.userLocationButton = userLocationButton
        }
         
     }
    
    //when screen was moved button must appear to give an option to set a tracking mode
    func mapView(_ mapView: MGLMapView, didChange mode: MGLUserTrackingMode, animated: Bool) {
        
    }
    func mapView(_ mapView: MGLMapView, regionDidChangeWith reason: MGLCameraChangeReason, animated: Bool) {
        print("regionDidChangeWith")
    }

    @IBAction func locationButtonTapped(sender: UserLocationUIButton) {
        //Jump to user location, but don't actually follow it.
        print("locationButtonTapped")
        mapView.userTrackingMode = .follow
        mapView.userTrackingMode = .none
        
    }
}

//SIZES AND IDENTIFIERS
struct ConstantSizes {
    let invisibleBusIconSize = CGSize(width: 1, height: 1)
    let visibleBusIconSize = CGSize(width: 20, height: 20)
    let busStopIconReuseIdentifier = "stop_icon"
    let busStopImageName = "bus_stop"
}
