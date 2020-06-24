//
//  NoBussesAvailableUILabel.swift
//  UCSCBus
//
// Developed by
// Radomyr Bezghin
// Nathan Lakritz
// Brian Thyfault
// Rizzian Ciprian Tuazon
// Copyright © 2020 BusTrackerTeam. All rights reserved.

import UIKit

class NoBussesAvailableUILabel: UILabel {
    
    //if label was tapped(dissmissed) once no need to show it again
    var labelWasDissmissed = false
    var textOffline = "All buses are offline"
    var textOnline = "Picking up some signal!"
    let durationAndDelay = 0.7 //used for animations
    let labelHeight: CGFloat = 50
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()

    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    func setup() {
        self.textAlignment = .center
        self.font = UIFont(name: "Halvetica", size: 17)
        self.textColor = UIColor.white
        self.text = "All busses are offline"
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .red
        self.layer.cornerRadius = 5
        self.layer.masksToBounds = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dissmissLabel(sender: ))))
        self.isUserInteractionEnabled = true
    }
    @objc func dissmissLabel(sender: UITapGestureRecognizer){ 
        labelWasDissmissed = true
        labelDissappear()
    }
    
    func labelAppear(){
        self.isHidden = false
        UIView.animate(withDuration: durationAndDelay) {
            self.transform = CGAffineTransform(translationX: 0, y: self.labelHeight)
        }
    }
    func labelDissappear() {
        UIView.animate(withDuration: durationAndDelay) {
            self.transform = CGAffineTransform(translationX: 0, y: -self.labelHeight)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + durationAndDelay) {
            self.isHidden = true
        }
    }
}
