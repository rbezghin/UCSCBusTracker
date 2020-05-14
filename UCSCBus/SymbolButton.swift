//
//  SymbolButton.swift
//  UCSCBus
//
//  Created by Brian Thyfault on 4/29/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//

import UIKit
import Mapbox

class SymbolButton: UIButton {
    private var symbolName: String
    private var symbolWeight: UIImage.SymbolWeight
    private var symbolColor: UIColor
    private var backColor: UIColor
    

    // Initializer to create the user tracking mode button
    init(symbolName: String, symbolWeight: UIImage.SymbolWeight, symbolColor: UIColor, backgroundColor: UIColor) {
        self.symbolName = symbolName
        self.symbolWeight = symbolWeight
        self.symbolColor = symbolColor
        backColor = backgroundColor
        super.init(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.backgroundColor = backgroundColor
        let scaleConfig = UIImage.SymbolConfiguration(scale: .large)
        let imageConfig = scaleConfig.applying(UIImage.SymbolConfiguration(weight: symbolWeight))
        let symbolImage = UIImage(systemName: symbolName, withConfiguration: imageConfig)?.withTintColor(symbolColor, renderingMode: .alwaysOriginal)
        self.setImage(symbolImage, for: .normal)
        self.layer.cornerRadius = 50/2
        self.alpha = 0.9
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateSymbol(color: UIColor, symbolName: String) {
        self.symbolName = symbolName
        let scaleConfig = UIImage.SymbolConfiguration(scale: .large)
        let imageConfig = scaleConfig.applying(UIImage.SymbolConfiguration(weight: symbolWeight))
        let symbolImage = UIImage(systemName: symbolName, withConfiguration: imageConfig)?.withTintColor(color, renderingMode: .alwaysOriginal)
        self.setImage(symbolImage, for: .normal)
        layoutIfNeeded()
    }
    
    override open var isHighlighted: Bool {
        didSet {
            self.backgroundColor = isHighlighted ? UIColor.lightText : backColor
        }
    }
}
