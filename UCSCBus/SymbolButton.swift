//
//  SymbolButton.swift
//  UCSCBus
//
//  Created by Brian Thyfault on 4/23/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//
import UIKit
import Mapbox

class SymbolButton: UIButton {
    private let symbolName: String

    // Initializer to create the user tracking mode button
    init(symbolName: String) {
        self.symbolName = symbolName
        super.init(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        self.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        let scaleConfig = UIImage.SymbolConfiguration(scale: .large)
        let weightConfig = UIImage.SymbolConfiguration(weight: .semibold)
        let infoImageConfig = scaleConfig.applying(weightConfig)
        let infoSymbolImage = UIImage(systemName: symbolName, withConfiguration: infoImageConfig)?.withTintColor(.black, renderingMode: .alwaysOriginal)
        self.setImage(infoSymbolImage, for: .normal)
        self.layer.cornerRadius = 4
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: 45).isActive = true
        self.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
