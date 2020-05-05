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
        .tg td{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;
          overflow:hidden;padding:10px 5px;word-break:normal;}
        .tg th{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;
          font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}
        .tg .tg-6z9x{background-color:#dddddd;font-family:serif !important;;text-align:left;vertical-align:top}
        .tg .tg-ysz0{background-color:#dddddd;text-align:left;vertical-align:top}
        .tg .tg-0lax{text-align:left;vertical-align:top}
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
            <td class="tg-0lax">7:25am-9:45pm</td>
            <td class="tg-0lax">7:25am-6:35pm</td>
            <td class="tg-0lax">No Service</td>
          </tr>
          <tr>
            <td class="tg-ysz0">Upper Campus</td>
            <td class="tg-0lax">7:30am-8:45pm</td>
            <td class="tg-0lax">7:30am-5:00pm</td>
            <td class="tg-0lax">No Service</td>
          </tr>
          <tr>
            <td class="tg-ysz0">Night Core</td>
            <td class="tg-0lax">8:00pm-12:00am</td>
            <td class="tg-0lax">6:00pm-12:00am</td>
            <td class="tg-0lax">5:00pm-12:00am</td>
          </tr>
        </table>
    """
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //infoTextView.attributedText = tableHTML.htmlToAttributedString;
    }
    

}
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
