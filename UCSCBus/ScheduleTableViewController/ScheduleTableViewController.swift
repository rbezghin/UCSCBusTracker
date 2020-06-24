//
//  ScheduleVC.swift
//  UCSCBus
//
// Developed by
// Radomyr Bezghin
// Nathan Lakritz
// Brian Thyfault
// Rizzian Ciprian Tuazon
// Copyright © 2020 BusTrackerTeam. All rights reserved.

import UIKit

class ScheduleTableViewController: UITableViewController {
    var busStopTitle: String? //assigned when bus stop is clicked
    //var busStopTitle = "Lower Campus (Outer)"
    let Data = DataSource() //where all the busstops data is stored
    var BusETAs: [BusETA] = [] //is filled with data after receiving it from the db
    
    let rowHeight: CGFloat = 80.0
    lazy var busImage = createImage(withSize: CGSize(width: 25, height: 25),withName: "stop_icon")
    
    let picker : UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.backgroundColor = .green
        picker.isUserInteractionEnabled = false
        picker.isHidden = true
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createBackButton()
        BusETAs.append(BusETA(id: "16", type: "Upper Campus", eta: 12))
        BusETAs.append(BusETA(id: "17", type: "Loop", eta: 23))
        BusETAs.append(BusETA(id: "18", type: "Loop", eta: 31))
        performDatabaseRequest {
            self.tableView.reloadData()
        }
    }
    // =======================================================================
    // MARK: - tableView
    // =======================================================================
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BusETAs.count
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        rowHeight
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  rowHeight;
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 100.0))
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = busStopTitle
        label.textAlignment = .center
        headerView.addSubview(label)
        return headerView
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")

        let date = Date()
        var calendar = Calendar.current
        if let timeZone = TimeZone(identifier: "PST") {
           calendar.timeZone = timeZone
        }
        var hour = calendar.component(.hour, from: date)
        var minute = calendar.component(.minute, from: date)
        //if(minute + tempETA[indexPath.row] > 60){
        let eta = BusETAs[indexPath.row].busETA
        if(minute + eta > 60){
            minute = minute + eta % 60
            hour += 1
            if (hour == 24){
                hour = 00
            }
        }
        cell.textLabel?.text = BusETAs[indexPath.row].busType
        cell.detailTextLabel?.text = "Scheduled at \(hour):\(minute+eta)"
        cell.imageView?.image = busImage
        cell.accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: rowHeight-20, height: rowHeight-20))
        let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: (cell.accessoryView?.frame.width)!, height: (cell.accessoryView?.frame.width)!))
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        //this must be a attributed string
        textLabel.numberOfLines = 0
        textLabel.text = "\(eta)\nmin"
        textLabel.textAlignment = .center
        textLabel.lineBreakMode = .byWordWrapping
        cell.accessoryView?.addSubview(textLabel)
        
        return cell
    }

    // =======================================================================
    // MARK: - pickerView
    // =======================================================================
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pickerVC = PickerViewController()
        //pickerVC.modalPresentationStyle = .fullScreen
        pickerVC.modalPresentationStyle = .overCurrentContext
        present(pickerVC, animated: true) {
        }
    }
    func createBackButton() {
        let closeButton = SymbolButton(symbolName: "xmark", symbolWeight: UIImage.SymbolWeight.regular, symbolColor: .label, backgroundColor: .systemGray4, size: 30, symbolScale: .medium)
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.view.addSubview(closeButton)
        //closeButton.frame = CGRect(x: 40, y: 40, width: 20, height: 20)
    
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
    }
    @objc func back() {
        self.dismiss(animated: true, completion: nil)
    }
  
    // =======================================================================
    // MARK: - Networking & parsing the data
    // =======================================================================
    /// Performs a request to the database
    /// which is made using the busStopTitle to differentiate it from other stops
    /// as a result it should receive ETA's for this specific busStop
    ///   - Parameters:
    ///   - completion: comletion handler to execute an update in tableView after request is completed
    func performDatabaseRequest(completion: @escaping (()-> ())){
        guard let url = URL(string: Data.urlString) else {return}
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 5.0)
        request.httpMethod = "POST"
        request.addValue(Data.contentTypeValue, forHTTPHeaderField: "Content-Type")
        guard let busTitle = busStopTitle else {return}
        guard let dataBaseName = Data.stopNameToDatabaseName[busTitle] else {return}
        let bodyData = "bus_stop=\(dataBaseName)"
        request.httpBody = bodyData.data(using: String.Encoding.utf8);
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print( "Error in task \(String(describing: error)) ")
                return
            }
            guard let data = data else {return}
            
            self.parseJSON(with: data)
            
            DispatchQueue.main.async {
                completion()
            }
        }.resume()
    }
    ///Parses data  received from the data base, puts it into the BusETA struct and then appends it to the array of BusETAs objects
    /// - Parameter data: data received from the server
    func parseJSON(with data: Data){
        do{
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonArray = jsonData as? [String: Any] else{
                print("JsonSerialization Failed")
                return
            }
            if let etaTableRows = jsonArray["rows"] as? NSArray{
                for etaData in etaTableRows{
                    if let etaDictionary = etaData as? NSDictionary{
                        guard let busID = etaDictionary["bus_id"] as? String else {return}
                        guard let busType = etaDictionary["bus_type"] as? String else {return}
                        guard let busTitle = busStopTitle else {return}
                        guard let busETAtitle = Data.stopNameToDatabaseName[busTitle] else {return}
                        guard let busETAString = etaDictionary[busETAtitle] as? String else {return}
                        let busETA = Int(busETAString) ?? 0
                        let newBusETA = BusETA(id: busID, type: busType, eta: busETA)
                        //BusETAs.append(newBusETA)
                    }
                }
            }
        }catch let error {
            print(error.localizedDescription)
            return
        }
    }
    // =======================================================================
    // MARK: - Helper Functions
    // =======================================================================
    /// Creates a resized icon for each cell
    /// - Parameters:
    ///   - size: enter a size for image as CGSize
    ///   - name: name for image in your assets
    /// - Returns: returns an optional UIImage
    func createImage(withSize size: CGSize,withName name: String) -> UIImage?{
        guard  let image = UIImage(named: name) else {return nil}
        var newImage: UIImage
        let renderer = UIGraphicsImageRenderer(size: size)
        newImage = renderer.image { (context) in
             image.draw(in: CGRect(origin: .zero, size: size))
        }
        return newImage
    }
}
// =======================================================================
// MARK: - ADTs
// =======================================================================
/// A data structure to hold information about ETA of each bus to a particular bus stop
struct BusETA {
    var busID: String
    var busType: String
    var busETA: Int
    
    init(id:String, type:String, eta: Int) {
        busID = id
        busType = type
        busETA = eta
    }
}
/// A data structure to keep all the string,static information about bus stops
struct DataSource {
    let urlString = "https://ucsc-bts3.soe.ucsc.edu/bus_stops/inner_eta2.php"
    let contentTypeValue = "application/x-www-form-urlencoded"
    var stopNameToDatabaseName: [String:String]
        =
    ["Campus Entrance (Main)":"Main_Entrance_ETA",
    "Lower Campus (Outer)":"Lower_Campus_ETA",
    "Village and the Farm (Outer)":"Village_Farm_ETA",
    "East Remote Lot Interior":"East_Remote_Interior_ETA",
    "East Remote Parking (Outer)":"East_Remote_ETA",
    "East Field House":"East_Field_House_ETA",
    "Cowell & Stevenson (Outer)":"Bookstore_ETA",
    "Crown & Merrill":"Crown_Merrill_ETA",
    "College 9 & 10 (Outer)":"Colleges9_10_ETA",
    "Science Hill (Outer)":"Science_Hill_ETA",
    "Kresge (Outer)":"Kresge_ETA",
    "Rachel Carson & Porter (Outer)":"Porter_RCC_ETA",
    "Family Student Housing":"Family_Student_Housing_ETA",
    "Oakes (Outer)":"Oakes_FSH_ETA",
    "Arboretum (Outer)":"Arboretum_ETA",
    "High and Western (Outer)":"Western_Drive_ETA",

    "Lower Campus (Inner)":"Lower_Campus_ETA",
    "Village and the Farm (Inner)":"Village_Farm_ETA",
    "East Remote Parking (Inner)":"East_Remote_ETA",
    "Cowell & Stevenson (Inner)":"Cowell_College_Bookstore_ETA",
    "College 9 & 10 (Inner)":"Colleges9_10_ETA",
    "Science Hill (Inner)":"Science_Hill_ETA",
    "Kresge (Inner)":"Kresge_ETA",
    "Kerr Hall Bridge":"Kerr_Hall_ETA",
    "Rachel Carson & Porter (Inner)":"Porter_RCC_ETA",
    "Oakes (Inner)":"Oakes_RCC_ETA",
    "West Remote Lot Interior":"West_Remote_Interior_ETA",
    "Arboretum (Inner)":"Arboretum_ETA",
    "High and Western (Inner)":"Western_Drive_ETA",
    "Campus Entrance (Barn Theater)":"Barn_Theater_ETA"]
}
