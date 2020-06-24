//
//  SymbolButton.swift
//  UCSCBus
//
// Developed by
// Radomyr Bezghin
// Nathan Lakritz
// Brian Thyfault
// Rizzian Ciprian Tuazon
// Copyright © 2020 BusTrackerTeam. All rights reserved.

import UIKit
import Mapbox

class SymbolButton: UIButton {
    private var symbolName: String
    private var symbolWeight: UIImage.SymbolWeight
    private var symbolColor: UIColor
    private var backColor: UIColor
    private var symbolScale: UIImage.SymbolScale
    

    // Initializer to create the user tracking mode button
    init(symbolName: String, symbolWeight: UIImage.SymbolWeight, symbolColor: UIColor, backgroundColor: UIColor, size: Int, symbolScale: UIImage.SymbolScale) {
        self.symbolName = symbolName
        self.symbolWeight = symbolWeight
        self.symbolColor = symbolColor
        self.symbolScale = symbolScale
        backColor = backgroundColor
        super.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        self.backgroundColor = backgroundColor
        let scaleConfig = UIImage.SymbolConfiguration(scale: symbolScale)
        let imageConfig = scaleConfig.applying(UIImage.SymbolConfiguration(weight: symbolWeight))
        let symbolImage = UIImage(systemName: symbolName, withConfiguration: imageConfig)?.withTintColor(symbolColor, renderingMode: .alwaysOriginal)
        self.setImage(symbolImage, for: .normal)
        self.layer.cornerRadius = CGFloat(size)/2
        self.alpha = 0.9
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalToConstant: CGFloat(size)).isActive = true
        self.heightAnchor.constraint(equalToConstant: CGFloat(size)).isActive = true
        
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
            self.backgroundColor = isHighlighted ? UIColor.secondarySystemBackground : backColor
        }
    }
}

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}
