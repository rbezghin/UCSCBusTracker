//
//  InfoViewController.swift
//  UCSCBus
//
//  Created by Brian Thyfault on 5/4/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var infoTextView: UITextView!
    
    let tableHTML = """
        <style type="text/css">
        .tg  {border-collapse:collapse;border-spacing:0;}
        .tg td{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:60px;
          overflow:hidden;padding:10px 5px;word-break:normal;}
        .tg th{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:60px;
          font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}
        .tg .tg-6z9x{background-color:#dddddd;font-family:serif !important;;text-align:center;vertical-align:middle}
        .tg .tg-ysz0{background-color:#dddddd;text-align:center;vertical-align:middle}
        .tg .tg-0lax{text-align:center;vertical-align:middle}
        </style>
        <table class="tg">
          <tr>
            <th class="tg-6z9x"><span style="font-weight:bold">Bus Times:</span></th>
            <th class="tg-ysz0">Mon-Thur</th>
            <th class="tg-ysz0">Friday</th>
            <th class="tg-ysz0">Sat-Sun</th>
          </tr>
          <tr>
            <td class="tg-ysz0">Loop</td>
            <td class="tg-0lax">7:25am-<br>9:45pm</td>
            <td class="tg-0lax">7:25am-<br>6:35pm</td>
            <td class="tg-0lax">No Service</td>
          </tr>
          <tr>
            <td class="tg-ysz0">Upper<br>Campus</td>
            <td class="tg-0lax">7:30am-<br>8:45pm</td>
            <td class="tg-0lax">7:30am-<br>5:00pm</td>
            <td class="tg-0lax">No Service</td>
          </tr>
          <tr>
            <td class="tg-ysz0">Night<br>Core</td>
            <td class="tg-0lax">8:00pm-<br>12:00am</td>
            <td class="tg-0lax">6:00pm-<br>12:00am</td>
            <td class="tg-0lax">5:00pm-<br>12:00am</td>
          </tr>
        </table>

    """
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        view.backgroundColor = .white
        createTableTextView()
    }
    
    func createTableTextView() {
        
        let attributedTable = tableHTML.htmlToAttributedString
        //let myAttribute = [ NSAttributedString.Key.font: UIFont(name: "SF Pro", size: 18.0)! ]
        attributedTable?.addAttribute(.font, value: UIFont.systemFont(ofSize: 13), range: NSRange(location: 0, length: attributedTable!.length))
        
        
        let tableTextView = UITextView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200))
        tableTextView.isEditable = false
        tableTextView.attributedText = attributedTable
        self.view.addSubview(tableTextView)
        tableTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        tableTextView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
    }

    
}
extension String {
    var htmlToAttributedString: NSMutableAttributedString? {
        guard let data = data(using: .utf8) else { return NSMutableAttributedString() }
        do {
            return try NSMutableAttributedString(data: data, options: [.documentType: NSMutableAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSMutableAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
