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
    
    var userLocationButton: SymbolButton?
    var loopRouteButton: SymbolButton?
    var upperCampusRouteButton: SymbolButton?
    var nightCoreRouteButton: SymbolButton?
    var label: NoBussesAvailableUILabel?
    let durationAndDelay = 0.7 //how long animation works
    
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
        setupLoopRouteButton()
        setupUpperCampusRouteButton()
        setupNightCoreRouteButton()
        setupInfoButton()
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        if mapView.userLocation?.coordinate.latitude == -180 { // if user doesn't allow their location
            mapView.setCenter(CLLocationCoordinate2D(latitude: 36.988792, longitude: -122.059351), zoomLevel: 13.2, animated: false)
            }
        else {
            mapView.setCenter((mapView.userLocation?.coordinate)!, zoomLevel: 14, animated: false)
            mapView.userTrackingMode = .follow
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
    
    
    
    func loadGeoJson(routetype: String) {
        DispatchQueue.global().async {
            guard let jsonUrl = Bundle.main.url(forResource: routetype, withExtension: "geojson") else {
                preconditionFailure("Failed to load local GeoJSON file")
            }
            guard let jsonData = try? Data(contentsOf: jsonUrl) else {
                preconditionFailure("Failed to parse GeoJSON file")
            }
            DispatchQueue.main.async {
                self.drawPolyline(geoJson: jsonData, routetype: routetype)
            }
        }
    }
    
    func drawPolyline(geoJson: Data, routetype: String) {
        guard let style = self.mapView.style else { return }

        guard let shapeFromGeoJSON = try? MGLShape(data: geoJson, encoding: String.Encoding.utf8.rawValue) else {
            fatalError("Could not generate MGLShape")
        }

        let source = MGLShapeSource(identifier: routetype, shape: shapeFromGeoJSON, options: nil)
        style.addSource(source)

        // Create new layer for the line.
        let layer = MGLLineStyleLayer(identifier: routetype, source: source)

        // Set the line join and cap to a rounded end.
        layer.lineJoin = NSExpression(forConstantValue: "round")
        layer.lineCap = NSExpression(forConstantValue: "round")

        // Set the line color to a constant blue color.
        if (routetype == "LoopRoute") {
            layer.lineColor = NSExpression(forConstantValue: UIColor.systemBlue)
        }
        else if (routetype == "UCRoute") {
            layer.lineColor = NSExpression(forConstantValue: UIColor.systemRed)
        }
        else if (routetype == "NCRoute") {
            layer.lineColor = NSExpression(forConstantValue: UIColor.systemIndigo)
        }

        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                       [14: 2, 18: 20])
        
        var routeIsDrawn = false
        for x in style.layers {
            if (x.identifier.contains("bus")) {
                style.insertLayer(layer, below: x)
                routeIsDrawn = true
                break;
            }
        }
        if (routeIsDrawn == false) {
            style.insertLayer(layer, above: style.layer(withIdentifier: "com.mapbox.annotations.points")!)
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
//                let testlocation = CLLocationCoordinate2D(latitude: 36.995699, longitude: -122.055357)
//                let testbus = Bus(id: 488392, busType: "NIGHT CORE", coordinate: testlocation)
//                Map.updateBusArray(newBus: testbus)
//                let testlocation1 = CLLocationCoordinate2D(latitude: 36.992631, longitude: -122.059928)
//                let testbus1 = Bus(id: 499282, busType: "LOOP", coordinate: testlocation1)
//                Map.updateBusArray(newBus: testbus1)
//                let testlocation2 = CLLocationCoordinate2D(latitude: 36.990631, longitude: -122.059928)
//                let testbus2 = Bus(id: 1234123, busType: "LOOP OUT OF SERVICE AT THE BARN THEATER", coordinate: testlocation2)
//                Map.updateBusArray(newBus: testbus2)
//                let testlocation3 = CLLocationCoordinate2D(latitude: 36.988631, longitude: -122.059928)
//                let testbus3 = Bus(id: 24594984, busType: "UPPER CAMPUS", coordinate: testlocation3)
//                Map.updateBusArray(newBus: testbus3)
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
        
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        let schedule = ScheduleTableViewController()
        if let optionalTitle = annotation.title, let title = optionalTitle{
            schedule.busStopTitle = title
            self.present(schedule, animated: true, completion: nil)
        }

    }
    
//    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
//        var etas = [String]()
//        var noETA = false
//
//        // Setting up HTTP POST request
//        let headers = [
//          "content-type": "application/x-www-form-urlencoded",
//          "cache-control": "no-cache",
//          "postman-token": "23cb4108-e24b-adab-b979-e37fd8f78622"
//        ]
//        //FIXME:  fatal error: Unexpectedly found nil while unwrapping an Optional value: line 180
//        guard let title = annotation.title else { print("error unwrapping in calloutAccessoryControlTapped"); return}
//        guard let titleTitle = title else { print("error unwrapping in calloutAccessoryControlTapped"); return}
//        let tryName = csvToDatabase[titleTitle] // use database name for request
//        guard let name = tryName else { print("error receiving from DB in calloutAccessoryControlTapped"); return}
//        let stopString = "bus_stop=" + name
//        var location = "outer_eta"
//        for stop in innerStops {
//            if annotation.title!! == stop {
//                location = "inner_eta"
//            }
//        }
//        let urlString = "https://ucsc-bts3.soe.ucsc.edu/bus_stops/" + location + ".php"
//        let postData = NSMutableData(data: stopString.data(using: String.Encoding.utf8)!)
//        var request = URLRequest(url: URL(string: urlString)! as URL,
//                                          cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
//                                          timeoutInterval: 10.0)
//        request.httpMethod = "POST"
//        request.allHTTPHeaderFields = headers
//        request.httpBody = postData as Data
//        print(stopString)
//        print(urlString)
//
//        // Sending HTTP POST request and processing response
//        let group = DispatchGroup()
//        group.enter()
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
//            if (error != nil) {
//                print(error!)
//            }
//            DispatchQueue.main.async {
//                do {
//                    let jsonObject = try JSONSerialization.jsonObject(with: data!)
//                    guard let jsonArray = jsonObject as? [String: Any] else{
//                        print("JsonSerialization Failed")
//                        return
//                        }
//                    if let etaTableRows = jsonArray["rows"] as? NSArray{
//                        for etaData in etaTableRows{
//                            let etaDictionary = etaData as? NSDictionary
//                            let busType = etaDictionary!["bus_type"] as! String
//                            let timeAway = String(etaDictionary!["time_away"] as! Int)
//                            let etaCell = busType + " is " + timeAway + " minutes away"
//                            etas.append(etaCell)
//                        }
//                    }
//                } catch {
//                    print("JSONSerialization error:", error)
//                    noETA = true
//                }
//                 group.leave()
//            }
//        })
//        dataTask.resume()
//        group.notify(queue: .main) { // Wait for HTTP section to complete before adding data to table
//            mapView.deselectAnnotation(annotation, animated: false)
//            let schedule = ScheduleTableViewController()
//            schedule.data.append(annotation.title!! + " ETAs:")
//            for item in etas {
//                schedule.data.append(item)
//            }
//            if noETA == true {
//                schedule.data.append("Sorry, ETAs not available!")
//            }
//            schedule.data.append("") // two line buffer
//            schedule.data.append("")
//            self.present(schedule, animated: true, completion: nil)
//        }
//    }
//
//    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor     annotation: MGLAnnotation) -> UIView? {
//
//        return UIButton(type: .detailDisclosure)
//    }

//    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
//            return true
//        }
    
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
                let busIconName = bus.busType
                let busImage: UIImage = {
                    let image = UIImage(named: busIconName)
                    let size = CGSize(width: 25, height: 25)
                    var newImage: UIImage
                    let renderer = UIGraphicsImageRenderer(size: size)
                    newImage = renderer.image { (context) in
                        image?.draw(in: CGRect(origin: .zero, size: size))
                    }
                    return newImage
                }()
                
                style.setImage(busImage, forName: bus.busImageName)
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
    

//for some reason this stopped working. used to work though
    // regionDidChangeAnimated to change visibility of bus stop annotations
//    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
//        print("regionView did change")
//        let zoomLevel = mapView.zoomLevel
//        if let annotationImage = mapView.dequeueReusableAnnotationImage(withIdentifier: SizesAndConstants.busStopIconReuseIdentifier){
//            if zoomLevel < 16 {
//                print("changing visibility")
//                let image = createImage(withSize: SizesAndConstants.invisibleBusIconSize, withName: SizesAndConstants.busStopImageName)
//                if let image = image{
//                    annotationImage.image = image
//                }
//            }
//            else{
//                let image = createImage(withSize: SizesAndConstants.visibleBusIconSize, withName: SizesAndConstants.busStopImageName)
//                if let image = image{
//                    annotationImage.image = image
//                }
//            }
//        }
//   }
    //fix
        func mapViewRegionIsChanging(_ mapView: MGLMapView) {
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
        //busses running not running
        label = setupLabelConstraints()
        if let label = label{
            let topAnchorConstaint = label.topAnchor
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
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
    
    // =======================================================================
    // MARK: - Buttons
    // =======================================================================
    
    func setupLoopRouteButton() {
        loopRouteButton = SymbolButton(symbolName: "", symbolWeight: .regular, symbolColor: .systemRed, backgroundColor: .systemBackground, size: 50, symbolScale: .default)
        loopRouteButton?.setTitle("L", for: .normal)
        loopRouteButton?.setTitleColor(.systemBlue, for: .normal)
        loopRouteButton?.setTitleColor(.systemBackground, for: .selected)
        loopRouteButton?.setBackgroundColor(color: .systemBlue, forState: .selected)
        loopRouteButton?.titleLabel?.font = UIFont(name: "SFProDisplay-Bold", size: 24)
        loopRouteButton?.addTarget(self, action: #selector(loopRouteButtonWasPressed), for: .touchUpInside)
        view.addSubview(loopRouteButton!)
        loopRouteButton?.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        loopRouteButton?.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
    }
    
    func setupUpperCampusRouteButton() {
        upperCampusRouteButton = SymbolButton(symbolName: "", symbolWeight: .regular, symbolColor: .systemRed, backgroundColor: .systemBackground, size: 50, symbolScale: .default)
        upperCampusRouteButton?.setTitle("UC", for: .normal)
        upperCampusRouteButton?.setTitleColor(.systemRed, for: .normal)
        upperCampusRouteButton?.setTitleColor(.systemBackground, for: .selected)
        upperCampusRouteButton?.setBackgroundColor(color: .systemRed, forState: .selected)
        upperCampusRouteButton?.titleLabel?.font = UIFont(name: "SFProDisplay-Bold", size: 24)
        upperCampusRouteButton?.addTarget(self, action: #selector(upperCampusRouteButtonWasPressed), for: .touchUpInside)
        view.addSubview(upperCampusRouteButton!)
        upperCampusRouteButton?.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        upperCampusRouteButton?.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
    }
    
    func setupNightCoreRouteButton() {
        nightCoreRouteButton = SymbolButton(symbolName: "", symbolWeight: .regular, symbolColor: .systemIndigo, backgroundColor: .systemBackground, size: 50, symbolScale: .default)
        nightCoreRouteButton?.setTitle("NC", for: .normal)
        nightCoreRouteButton?.setTitleColor(.systemIndigo, for: .normal)
        nightCoreRouteButton?.setTitleColor(.systemBackground, for: .selected)
        nightCoreRouteButton?.setBackgroundColor(color: .systemIndigo, forState: .selected)
        nightCoreRouteButton?.titleLabel?.font = UIFont(name: "SFProDisplay-Bold", size: 24)
        nightCoreRouteButton?.addTarget(self, action: #selector(nightCoreRouteButtonWasPressed), for: .touchUpInside)
        view.addSubview(nightCoreRouteButton!)
        nightCoreRouteButton?.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -160).isActive = true
        nightCoreRouteButton?.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
    }
    
    @objc func loopRouteButtonWasPressed(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected == true {
            loadGeoJson(routetype: "LoopRoute")
        }
        else {
            self.mapView.style?.removeLayer((mapView.style?.layer(withIdentifier: "LoopRoute"))!)
            self.mapView.style?.removeSource((mapView.style?.source(withIdentifier: "LoopRoute"))!)
        }
    }
    
    @objc func upperCampusRouteButtonWasPressed(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected == true {
            loadGeoJson(routetype: "UCRoute")
        }
        else {
            self.mapView.style?.removeLayer((mapView.style?.layer(withIdentifier: "UCRoute"))!)
            self.mapView.style?.removeSource((mapView.style?.source(withIdentifier: "UCRoute"))!)
        }
    }
    
    @objc func nightCoreRouteButtonWasPressed(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected == true {
            loadGeoJson(routetype: "NCRoute")
        }
        else {
            self.mapView.style?.removeLayer((mapView.style?.layer(withIdentifier: "NCRoute"))!)
            self.mapView.style?.removeSource((mapView.style?.source(withIdentifier: "NCRoute"))!)
        }
    }
    
    func setupLocationButton() {
        userLocationButton = SymbolButton(symbolName: "location.fill", symbolWeight: UIImage.SymbolWeight.medium, symbolColor: .systemBlue, backgroundColor: .systemBackground, size: 50, symbolScale: .large)
        userLocationButton?.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
        view.addSubview(userLocationButton!)
        userLocationButton?.translatesAutoresizingMaskIntoConstraints = false
        userLocationButton?.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        userLocationButton?.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
     }
    
    @objc func locationButtonTapped(sender: SymbolButton) {
        //Jump to user location, but don't actually follow it.
        //print("locationButtonTapped")
        mapView.setZoomLevel(14, animated: true)
        mapView.userTrackingMode = .follow
        updateArrowForTrackingMode(mode: mapView.userTrackingMode, button: sender)
    }
    
    func updateArrowForTrackingMode(mode: MGLUserTrackingMode, button: SymbolButton) {
        //print("Updating Arrow")
        switch mode {
        case .follow:
            userLocationButton?.updateSymbol(color: .systemBlue, symbolName: "location.fill")
        case .none:
            userLocationButton?.updateSymbol(color: .label, symbolName: "location")
        default:
            userLocationButton?.updateSymbol(color: .label, symbolName: "location")
        }
    }
    
    //When screen was moved button must appear to give an option to set a tracking mode
    func mapView(_ mapView: MGLMapView, didChange mode: MGLUserTrackingMode, animated: Bool) {
        if let userLocationButton = userLocationButton {
            updateArrowForTrackingMode(mode: mode, button: userLocationButton)
        }
    }
    
    //This adds the circular "i" button to bring up the "Info & Settings" view
    func setupInfoButton() {
        let infoButton = SymbolButton(symbolName: "info.circle", symbolWeight: UIImage.SymbolWeight.medium, symbolColor: .label, backgroundColor: .systemBackground, size: 50, symbolScale: .large)
        infoButton.addTarget(self, action: #selector(infoSegue), for: .touchUpInside)
        view.addSubview(infoButton)
        infoButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        infoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
    }
    
    @objc func infoSegue(sender: SymbolButton) {
        let infoVC = InfoViewController()
        //infoVC.modalPresentationStyle = .fullscreen
        self.present(infoVC, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.darkContent
    }
        
}

//SIZES AND IDENTIFIERS
struct ConstantSizes {
    let invisibleBusIconSize = CGSize(width: 1, height: 1)
    let visibleBusIconSize = CGSize(width: 20, height: 20)
    let busStopIconReuseIdentifier = "stop_icon"
    let busStopImageName = "bus_stop"
}
