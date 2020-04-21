//
//  NoBussesAvailableUILabel.swift
//  UCSCBus
//
//  Created by Radomyr Bezghin on 4/20/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//

import UIKit

class NoBussesAvailableLabel: UILabel {
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
        
        UIView.animate(withDuration: 10) {
            self.isHidden = true
        }
        
    }
    
}
