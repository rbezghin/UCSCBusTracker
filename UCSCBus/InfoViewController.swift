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
        .tg td{border-bottom: 1px solid #dddddd;font-family:Arial, sans-serif;font-size:60px;
          overflow:hidden;padding:6px 5px;word-break:normal;}
        .tg th{border-bottom: 1px solid #dddddd;font-family:Arial, sans-serif;font-size:60px;
          font-weight:normal;overflow:hidden;padding:5px 5px;word-break:normal;}
        .tg .tg-6z9x{border-right: 1px solid #dddddd;font-family:serif !important;;text-align:center;vertical-align:middle}
        .tg .tg-ysz0{text-align:center;vertical-align:middle}
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
            <td class="tg-6z9x">Loop</td>
            <td class="tg-0lax">7:25am-<br>9:45pm</td>
            <td class="tg-0lax">7:25am-<br>6:35pm</td>
            <td class="tg-0lax">No<br>Service</td>
          </tr>
          <tr>
            <td class="tg-6z9x">Upper<br>Campus</td>
            <td class="tg-0lax">7:30am-<br>8:45pm</td>
            <td class="tg-0lax">7:30am-<br>5:00pm</td>
            <td class="tg-0lax">No<br>Service</td>
          </tr>
          <tr>
            <td class="tg-6z9x">Night<br>Core</td>
            <td class="tg-0lax">8:00pm-<br>12:00am</td>
            <td class="tg-0lax">6:00pm-<br>12:00am</td>
            <td class="tg-0lax">5:00pm-<br>12:00am</td>
          </tr>
        </table>
    """
    var tableTextView:UITextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modalPresentationStyle = .fullScreen
        view.backgroundColor = .white
        //createNavBar()
        createBackButton()
        addBusImages()
        addBusText()
        createTableTextView()
        addAcknowledgements()
        
//        for family:String in UIFont.familyNames {
//            print(family)
//            for names:String in UIFont.fontNames(forFamilyName: family) {
//                print("==\(names)")
//            }
//        }
    }
    
    func createTableTextView() {
        
        let attributedTable = tableHTML.htmlToAttributedString
        //let myAttribute = [ NSAttributedString.Key.font: UIFont(name: "SF Pro", size: 18.0)! ]
        attributedTable?.addAttribute(.font, value: UIFont(name: "SFProDisplay-Regular", size: 13), range: NSRange(location: 0, length: attributedTable!.length))
        //print(attributedTable)
        attributedTable?.addAttribute(.font, value: UIFont(name: "SFProDisplay-Bold", size: 13), range: NSRange(location: 0, length: 10))
        tableTextView = UITextView(frame: CGRect(x: 0, y: 90, width: self.view.frame.width, height: 185))
        tableTextView.isEditable = false
        tableTextView.attributedText = attributedTable
        //tableTextView.backgroundColor = UIColor.systemTeal
        tableTextView.isScrollEnabled = false
        self.view.addSubview(tableTextView)
        tableTextView.translatesAutoresizingMaskIntoConstraints = false
        tableTextView.topAnchor.constraint(equalTo: outOfServiceImageView.bottomAnchor, constant: 10).isActive = true
        tableTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        tableTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        tableTextView.heightAnchor.constraint(equalToConstant: 185).isActive = true
        //tableTextView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 40).isActive = true
        //tableTextView.updateConstraints()
    }

    func createNavBar() {
        let width = self.view.frame.width
        let navigationBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: width, height: 100))
        //navigationBar.backgroundColor = .clear
        let navigationItem = UINavigationItem(title: "App Info")
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(back))
        navigationItem.rightBarButtonItem = doneButton
        navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationBar.setItems([navigationItem], animated: false)
        self.view.addSubview(navigationBar)
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
        
        let title: UILabel = UILabel(frame: CGRect(x: 10, y: 20, width: view.frame.width - 50, height: 70))
        title.text = "App Info"
        title.font = UIFont(name: "SFProDisplay-Heavy", size: 35)
        //title.adjustsFontSizeToFitWidth = true
        //title.font = UIFont.boldSystemFont(ofSize: 40)
        
        view.addSubview(title)
        
    }
    
    var loopImageView: UIImageView = UIImageView()
    var upperCampusImageView: UIImageView = UIImageView()
    var nightCoreImageView: UIImageView = UIImageView()
    var outOfServiceImageView: UIImageView = UIImageView()
    var imageRatio: CGFloat = 0.0
    
    func addBusImages() {
        let loopImage = UIImage(named: "Blue Bus")
        let upperCampusImage = UIImage(named: "Red Bus")
        let nightCoreImage = UIImage(named: "Indigo Bus")
        let outOfServiceImage = UIImage(named: "White Bus")
        imageRatio = (loopImage?.size.width)! / (loopImage?.size.height)!
        loopImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        upperCampusImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        nightCoreImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        outOfServiceImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        
        
        loopImageView.contentMode = UIView.ContentMode.scaleAspectFit
        upperCampusImageView.contentMode = UIView.ContentMode.scaleAspectFit
        nightCoreImageView.contentMode = UIView.ContentMode.scaleAspectFit
        outOfServiceImageView.contentMode = UIView.ContentMode.scaleAspectFit
        
        loopImageView.image = loopImage
        upperCampusImageView.image = upperCampusImage
        nightCoreImageView.image = nightCoreImage
        outOfServiceImageView.image = outOfServiceImage
        
        view.addSubview(loopImageView)
        view.addSubview(upperCampusImageView)
        view.addSubview(nightCoreImageView)
        view.addSubview(outOfServiceImageView)
        
        loopImageView.translatesAutoresizingMaskIntoConstraints = false
        upperCampusImageView.translatesAutoresizingMaskIntoConstraints = false
        nightCoreImageView.translatesAutoresizingMaskIntoConstraints = false
        outOfServiceImageView.translatesAutoresizingMaskIntoConstraints = false
        
        loopImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
        upperCampusImageView.topAnchor.constraint(equalTo: loopImageView.bottomAnchor, constant: 5).isActive = true
        nightCoreImageView.topAnchor.constraint(equalTo: upperCampusImageView.bottomAnchor, constant: 5).isActive = true
        outOfServiceImageView.topAnchor.constraint(equalTo: nightCoreImageView.bottomAnchor, constant: 5).isActive = true
        loopImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        upperCampusImageView.leadingAnchor.constraint(equalTo: loopImageView.leadingAnchor).isActive = true
        nightCoreImageView.leadingAnchor.constraint(equalTo: upperCampusImageView.leadingAnchor).isActive = true
        outOfServiceImageView.leadingAnchor.constraint(equalTo: nightCoreImageView.leadingAnchor).isActive = true
        
        loopImageView.heightAnchor.constraint(equalToConstant: 100/imageRatio).isActive = true
        upperCampusImageView.heightAnchor.constraint(equalToConstant: 100/imageRatio).isActive = true
        nightCoreImageView.heightAnchor.constraint(equalToConstant: 100/imageRatio).isActive = true
        outOfServiceImageView.heightAnchor.constraint(equalToConstant: 100/imageRatio).isActive = true
        loopImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        upperCampusImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        nightCoreImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        outOfServiceImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    func addBusText() {
        let loopLabel = UILabel(frame: CGRect(x:0, y: 300, width: 100, height: 50))
        let upperCampusLabel = UILabel(frame: CGRect(x:0, y: 300, width: 100, height: 50))
        let nightCoreLabel = UILabel(frame: CGRect(x:0, y: 300, width: 100, height: 50))
        let outOfServiceLabel = UILabel(frame: CGRect(x:0, y: 300, width: 100, height: 50))
        
        loopLabel.font = UIFont(name: "SFProDisplay-Regular", size: 18)
        upperCampusLabel.font = UIFont(name: "SFProDisplay-Regular", size: 18)
        nightCoreLabel.font = UIFont(name: "SFProDisplay-Regular", size: 18)
        outOfServiceLabel.font = UIFont(name: "SFProDisplay-Regular", size: 18)
        
        loopLabel.text = "Loop"
        upperCampusLabel.text = "Upper Campus"
        nightCoreLabel.text = "Night Core"
        outOfServiceLabel.text = "Out of Service at Barn Theater"
        
        view.addSubview(loopLabel)
        view.addSubview(upperCampusLabel)
        view.addSubview(nightCoreLabel)
        view.addSubview(outOfServiceLabel)
        
        loopLabel.translatesAutoresizingMaskIntoConstraints = false
        upperCampusLabel.translatesAutoresizingMaskIntoConstraints = false
        nightCoreLabel.translatesAutoresizingMaskIntoConstraints = false
        outOfServiceLabel.translatesAutoresizingMaskIntoConstraints = false
        
        loopLabel.centerYAnchor.constraint(equalTo: loopImageView.centerYAnchor).isActive = true
        upperCampusLabel.centerYAnchor.constraint(equalTo: upperCampusImageView.centerYAnchor).isActive = true
        nightCoreLabel.centerYAnchor.constraint(equalTo: nightCoreImageView.centerYAnchor).isActive = true
        outOfServiceLabel.centerYAnchor.constraint(equalTo: outOfServiceImageView.centerYAnchor).isActive = true
        
        loopLabel.leadingAnchor.constraint(equalTo: loopImageView.trailingAnchor, constant: 10).isActive = true
        upperCampusLabel.leadingAnchor.constraint(equalTo: upperCampusImageView.trailingAnchor, constant: 10).isActive = true
        nightCoreLabel.leadingAnchor.constraint(equalTo: nightCoreImageView.trailingAnchor, constant: 10).isActive = true
        outOfServiceLabel.leadingAnchor.constraint(equalTo: outOfServiceImageView.trailingAnchor, constant: 10).isActive = true
        loopLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        upperCampusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        nightCoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        outOfServiceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        loopLabel.heightAnchor.constraint(equalToConstant: 100/imageRatio).isActive = true
        upperCampusLabel.heightAnchor.constraint(equalToConstant: 100/imageRatio).isActive = true
        nightCoreLabel.heightAnchor.constraint(equalToConstant: 100/imageRatio).isActive = true
        outOfServiceLabel.heightAnchor.constraint(equalToConstant: 100/imageRatio).isActive = true
    }
    
    func addAcknowledgements() {
        var sectionTitle = UILabel()
        sectionTitle.text = "Made with ❤️ by:"
        sectionTitle.font = UIFont(name: "SFProDisplay-Bold", size: 18)
        view.addSubview(sectionTitle)
        sectionTitle.translatesAutoresizingMaskIntoConstraints = false
        sectionTitle.topAnchor.constraint(equalTo: tableTextView.bottomAnchor, constant: 20).isActive = true
        sectionTitle.heightAnchor.constraint(equalToConstant: 24).isActive = true
        sectionTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        sectionTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
        
        
        var softwareNamesTextView = UITextView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        softwareNamesTextView.isEditable = false
        softwareNamesTextView.isScrollEnabled = false
        softwareNamesTextView.isSelectable = false
        let softwareAttributedString = NSMutableAttributedString(string: "Software:\nBrian Thyfault\nRadomyr Bezghin\nRizzian Tuazon\nNathan Lakritz")
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        softwareAttributedString.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: softwareAttributedString.length - 1))
        softwareAttributedString.addAttribute(.font, value: UIFont(name: "SFProDisplay-Medium", size: 16), range: NSRange(location: 0, length: 9))
        softwareAttributedString.addAttribute(.font, value: UIFont(name: "SFProDisplay-Light", size: 16), range: NSRange(location: 10, length: softwareAttributedString.length - 10))
        softwareNamesTextView.attributedText = softwareAttributedString
        //softwareNamesTextView.font = UIFont(name: "SFProDisplay-Light", size: 24)
        view.addSubview(softwareNamesTextView)
        softwareNamesTextView.translatesAutoresizingMaskIntoConstraints = false
        softwareNamesTextView.topAnchor.constraint(equalTo: sectionTitle.bottomAnchor, constant: 5).isActive = true
        softwareNamesTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        softwareNamesTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        softwareNamesTextView.trailingAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        
        var hardwareNamesTextView = UITextView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        hardwareNamesTextView.isEditable = false
        hardwareNamesTextView.isScrollEnabled = false
        hardwareNamesTextView.isSelectable = false
        let hardwareAttributedString = NSMutableAttributedString(string: "Hardware:\nKatelyn Young\nGavin Haight\nFarinaz Rezvani\nAlexander Zuo")
        hardwareAttributedString.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: hardwareAttributedString.length - 1))
        hardwareAttributedString.addAttribute(.font, value: UIFont(name: "SFProDisplay-Medium", size: 16), range: NSRange(location: 0, length: 9))
        hardwareAttributedString.addAttribute(.font, value: UIFont(name: "SFProDisplay-Light", size: 16), range: NSRange(location: 10, length: hardwareAttributedString.length - 10))
        hardwareNamesTextView.attributedText = hardwareAttributedString
        //softwareNamesTextView.font = UIFont(name: "SFProDisplay-Light", size: 24)
        view.addSubview(hardwareNamesTextView)
        hardwareNamesTextView.translatesAutoresizingMaskIntoConstraints = false
        hardwareNamesTextView.topAnchor.constraint(equalTo: sectionTitle.bottomAnchor, constant: 5).isActive = true
        hardwareNamesTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
        hardwareNamesTextView.leadingAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        hardwareNamesTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        
    }
    
//    public override func draw(_ rect: CGRect) {
//        let context = UIGraphicsGetCurrentContext()
//        context!.setLineWidth(2.0)
//        context!.setStrokeColor((UIColor.red.cgColor))
//        context?.move(to: CGPoint(x: 0, y: 0))
//        context?.addLine(to: CGPoint(x: 100, y: 100))
//        context!.strokePath()
//        let aPath = UIBezierPath()
//        aPath.move(to: CGPoint(x: 20, y: 20))
//        aPath.addLine(to: CGPoint(x: 50, y: 50))
//        aPath.close()
//        UIColor.black.set()
//        aPath.stroke()
//    }
    
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
