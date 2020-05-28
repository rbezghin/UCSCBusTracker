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
            <th class="tg-6z9x"><span style="font-weight:bold">Bus<br>Times:</span></th>
            <th class="tg-ysz0">Mon-Thur</th>
            <th class="tg-ysz0">Friday</th>
            <th class="tg-ysz0">Sat-Sun</th>
          </tr>
          <tr>
            <td class="tg-ysz0">Loop</td>
            <td class="tg-0lax">7:25am-<br>9:45pm</td>
            <td class="tg-0lax">7:25am-<br>6:35pm</td>
            <td class="tg-0lax">No<br>Service</td>
          </tr>
          <tr>
            <td class="tg-ysz0">Upper<br>Campus</td>
            <td class="tg-0lax">7:30am-<br>8:45pm</td>
            <td class="tg-0lax">7:30am-<br>5:00pm</td>
            <td class="tg-0lax">No<br>Service</td>
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
        createNavBar()
        //createBackButton()
//        for family:String in UIFont.familyNames {
//            print(family)
//            for names:String in UIFont.fontNames(forFamilyName: family) {
//                print("==\(names)")
//            }
//        }
    }
    
    func createTitle() {
        
    }
    
    func createTableTextView() {
        
        let attributedTable = tableHTML.htmlToAttributedString
        //let myAttribute = [ NSAttributedString.Key.font: UIFont(name: "SF Pro", size: 18.0)! ]
        attributedTable?.addAttribute(.font, value: UIFont.systemFont(ofSize: 13), range: NSRange(location: 0, length: attributedTable!.length))
        
        
        let tableTextView = UITextView(frame: CGRect(x: 0, y: 100, width: self.view.frame.width, height: 300))
        tableTextView.isEditable = false
        tableTextView.attributedText = attributedTable
        self.view.addSubview(tableTextView)
        //tableTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        //tableTextView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 40).isActive = true
        //tableTextView.updateConstraints()
    }

    func createNavBar() {
        let width = self.view.frame.width
        let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: width, height: 100))
        self.view.addSubview(navigationBar)
        //navigationBar.backgroundColor = .clear
        let navigationItem = UINavigationItem(title: "Info & Settings")
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(back))
        navigationItem.rightBarButtonItem = doneButton
        navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationBar.setItems([navigationItem], animated: false)
    }
    
    func createToolBar() {
        
        self.navigationController?.isToolbarHidden = false
        let toolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 44))
        
        var items = [UIBarButtonItem]()
        //items.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        items.append(
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(back))
        )
        //toolbarItems = items
        toolbar.items = items
        self.view.addSubview(toolbar)
    }
    
    @objc func back() {
        print("Back!")
        let mapview = MapViewController()
        mapview.modalPresentationStyle = .fullScreen
        self.dismiss(animated: true, completion: nil)
        //present(mapview, animated: true, completion: nil)
    }
    
    func createBackButton() {
        let closeButton = SymbolButton(symbolName: "xmark", symbolWeight: UIImage.SymbolWeight.regular, symbolColor: .label, backgroundColor: .systemGray4, size: 30, symbolScale: .medium)
        closeButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.view.addSubview(closeButton)
        //closeButton.frame = CGRect(x: 40, y: 40, width: 20, height: 20)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        let title: UILabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.width - 50, height: 70))
        title.text = "Info & Settings"
        title.font = UIFont(name: "SFProDisplay-Heavy", size: 40)
        //title.adjustsFontSizeToFitWidth = true
        //title.font = UIFont.boldSystemFont(ofSize: 40)
        
        view.addSubview(title)
        
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
