//
//  ScheduleVC.swift
//  UCSCBus
//
//  Created by Radomyr Bezghin on 2/1/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//

import UIKit

class ScheduleVC: UITableViewController {
    var data = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }
    
    override func viewDidLayoutSubviews() {
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        let height = bounds.size.height
        self.tableView.frame = CGRect(x: 0, y: 500, width: width, height: height/2)
        self.tableView.layer.cornerRadius = 12; // for rounded corners
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0; // changing row height from default 44 to 50
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
}
