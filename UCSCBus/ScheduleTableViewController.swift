//
//  ScheduleVC.swift
//  UCSCBus
//
//  Created by Radomyr Bezghin on 2/1/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//TO DO;
//create a request to the DB using bus stop name
//parse ETAs
//display them
//make cell nicer
//make tableView nicer maybe?
//add notifications (prof request)



import UIKit

class ScheduleTableViewController: UITableViewController {
    var data = [String]()
    var busStopTitle: String?
    //TEMP DATA
    let tempDataNum = 6
    let tempETA = [1,7,15,23,27,30]
    let tempBusName = ["INNER Loop","UPPER Campus", "INNER Loop", "INNER Loop", "INNER Loop", "UPPER CAMPUS"]
    
    
    let rowHeight = 80.0
    lazy var busImage = createImage(withSize: CGSize(width: 25, height: 25),withName: "stop_icon")
    //(named: "stop_icon")!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //time to get the ETA data
        performDatabaseRequest()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        //return data.count
        return tempDataNum
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        80
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  CGFloat(rowHeight); // changing row height from default 44 to 50
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
        if(minute + tempETA[indexPath.row] > 60){
            minute = minute + tempETA[indexPath.row] % 60
            hour += 1
            if (hour == 24){
                hour = 00
            }
        }
        cell.textLabel?.text = tempBusName[indexPath.row]
        cell.detailTextLabel?.text = "Scheduled at \(hour):\(minute+tempETA[indexPath.row])"
        cell.imageView?.image = busImage
        cell.accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: rowHeight-20, height: rowHeight-20))
        let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: (cell.accessoryView?.frame.width)!, height: (cell.accessoryView?.frame.width)!))
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        //this must be a attributed string
        textLabel.numberOfLines = 0
        textLabel.text = "\(tempETA[indexPath.row])\nmin"
        textLabel.textAlignment = .center
        textLabel.lineBreakMode = .byWordWrapping
        cell.accessoryView?.addSubview(textLabel)
        return cell
    }
    
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
    /// Performs a request to the database
    /// which is made using the busStopTitle to differentiate it from other stops
    /// as a result it should receive ETA's for this specific busStop
    func performDatabaseRequest(){
        
    }
}
