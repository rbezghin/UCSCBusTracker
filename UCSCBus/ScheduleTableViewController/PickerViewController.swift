//
//  PickerViewController.swift
//  UCSCBus
//
//  Created by Radomyr Bezghin on 6/2/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//

import UIKit
import UserNotifications

class PickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate  {
    
    let picker : UIPickerView = {
        let picker = UIPickerView()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.isUserInteractionEnabled = true
        picker.backgroundColor = .white
        return picker
    }()
    let customView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.autoresizesSubviews = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        view.layer.cornerRadius = 15
            
        return view
    }()
    let belowTitleSpacing: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let belowPickerSpacing: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Set a reminder"
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        return label
    }()
    let okButton: UIButton = {
        let button = UIButton()
        button.setTitle("OK", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(OKButtonSetNotificationAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.textColor = .systemRed
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelViewButtonAction), for: .touchUpInside)
        return button
    }()
    let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 1
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.dataSource = self
        picker.delegate = self
        picker.selectRow(2, inComponent: 0, animated: false)
        
        view.addSubview(customView)
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        
        stack.addArrangedSubview(okButton)
        stack.addArrangedSubview(cancelButton)
        
        customView.addSubview(picker)
        customView.addSubview(titleLabel)
        customView.addSubview(stack)
        customView.addSubview(belowTitleSpacing)
        customView.addSubview(belowPickerSpacing)
        
        addConstraints()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return 5
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return "Remind in \((row + 1) * 5)"
    }
    
    func addConstraints(){
        customView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        customView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        customView.heightAnchor.constraint(equalToConstant: view.bounds.size.height * 0.35).isActive = true
        customView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        customView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant:  -15).isActive = true

        titleLabel.topAnchor.constraint(equalTo: customView.topAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: customView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        belowTitleSpacing.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        belowTitleSpacing.leadingAnchor.constraint(equalTo: customView.leadingAnchor).isActive = true
        belowTitleSpacing.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
        belowTitleSpacing.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        picker.topAnchor.constraint(equalTo: belowTitleSpacing.bottomAnchor).isActive = true
        picker.leadingAnchor.constraint(equalTo: customView.leadingAnchor).isActive = true
        picker.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
        picker.bottomAnchor.constraint(equalTo: belowPickerSpacing.topAnchor).isActive = true
        
        belowPickerSpacing.leadingAnchor.constraint(equalTo: customView.leadingAnchor).isActive = true
        belowPickerSpacing.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
        belowPickerSpacing.heightAnchor.constraint(equalToConstant: 1).isActive = true
        belowPickerSpacing.bottomAnchor.constraint(equalTo: stack.topAnchor).isActive = true
        
        stack.leadingAnchor.constraint(equalTo: customView.leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: customView.trailingAnchor).isActive = true
        stack.heightAnchor.constraint(equalToConstant: 50).isActive = true
        stack.bottomAnchor.constraint(equalTo: customView.bottomAnchor).isActive = true
    }
    @objc func cancelViewButtonAction(){
        self.presentingViewController?.dismiss(animated: true)
    }
    @objc func OKButtonSetNotificationAction(){
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                self.setupNotification()
            } else {
                print("D'oh")
            }
        }
    }
    func setupNotification() {
        
        //let center = UNUserNotificationCenter.current()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let content = UNMutableNotificationContent()
        content.title = "BusTracker Alert"
        content.body = "It's time to get on the bus!"
        content.categoryIdentifier = "customIdentifier"
        content.userInfo = ["customData": "busReminder"]
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "busAlert", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if (error != nil){
                print(error?.localizedDescription)
            }
            
        }
        self.presentingViewController?.dismiss(animated: true)
    }

}
