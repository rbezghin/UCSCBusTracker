//
//  ScheduleVC.swift
//  UCSCBus
//
//  Created by Radomyr Bezghin on 2/1/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//

import UIKit

class ScheduleTableViewController: UITableViewController {
    var data = [String]()
    let rowHeight = 80.0
    lazy var busImage = createImage(withSize: CGSize(width: 25, height: 25),withName: "stop_icon")
    //(named: "stop_icon")!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.title = "Bus stop name"
//        self.tableView.sectionHeaderHeight = 100
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        80
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.size.width, height: 100.0))
        let label = UILabel()
        label.frame = CGRect.init(x: 5, y: 5, width: headerView.frame.width-10, height: headerView.frame.height-10)
        label.text = "Bus stop NAME"
        label.textAlignment = .center
        headerView.addSubview(label)
        return headerView
    }
    
//    override func viewDidLayoutSubviews() {
//        let bounds = UIScreen.main.bounds
//        let width = bounds.size.width
//        let height = bounds.size.height
//        let yPoint = Int(height*0.56)
//        self.tableView.frame = CGRect(x: 0, y: CGFloat(yPoint), width: width, height: height/2)
//        self.tableView.layer.cornerRadius = 12; // for rounded corners
//    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  CGFloat(rowHeight); // changing row height from default 44 to 50
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        //print(data)
        //cell.detailTextLabel?.text = data[indexPath.row]

        cell.textLabel?.text = "bus name"
        cell.detailTextLabel?.text = "bus details"
        cell.imageView?.image = busImage
        cell.accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: rowHeight-20, height: rowHeight-20))
        let textLabel = UILabel(frame: CGRect(x: 0, y: 0, width: (cell.accessoryView?.frame.width)!, height: (cell.accessoryView?.frame.width)!))
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        //this must be a attributed string
        textLabel.numberOfLines = 0
        textLabel.text = "00\nmin"
        textLabel.textAlignment = .center
        textLabel.lineBreakMode = .byWordWrapping
        cell.accessoryView?.addSubview(textLabel)
        
        //textLabel.centerXAnchor.constraint(equalTo: cell.accessoryView!.centerXAnchor).isActive = true
        //textLabel.centerYAnchor.constraint(equalTo: cell.accessoryView!.centerYAnchor).isActive = true
        
        return cell
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
}
