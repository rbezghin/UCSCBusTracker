//
//  UserLocationButton.swift
//  UCSCBus
//
//  Created by Radomyr Bezghin on 3/5/20.
//  Copyright © 2020 Radomyr Bezghin. All rights reserved.
//

import UIKit
import Mapbox



class UserLocationUIButton: UIButton {
    private var arrow: CAShapeLayer?
    private let buttonSize: CGFloat
    private let blueColor = "#0984e3"
    
    // Initializer to create the user tracking mode button
    init(buttonSize: CGFloat) {
        self.buttonSize = buttonSize
        super.init(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = self.frame.size.width/2

        let arrow = CAShapeLayer()
        arrow.path = arrowPath()
        
        arrow.lineWidth = 1.5
        arrow.lineJoin = CAShapeLayerLineJoin.round
        arrow.bounds = CGRect(x: 0, y: 0, width: buttonSize / 2.3, height: buttonSize / 2.3)
        arrow.position = CGPoint(x: buttonSize / 2, y: buttonSize / 2)
        arrow.shouldRasterize = true
        arrow.rasterizationScale = UIScreen.main.scale
        arrow.drawsAsynchronously = false
        arrow.transform = CATransform3DMakeRotation(19.6, 0, 0, 1)
        //arrow.transform = transfor
        self.arrow = arrow
        
        // Update arrow for initial tracking mode
        updateArrowForTrackingMode(mode: .follow)
        layer.addSublayer(self.arrow!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func arrowPath() -> CGPath {
        let bezierPath = UIBezierPath()
        let max: CGFloat = buttonSize / 2.3
        bezierPath.move(to: CGPoint(x: max * 0.5, y: 0))
        bezierPath.addLine(to: CGPoint(x: max * 0.1, y: max))
        bezierPath.addLine(to: CGPoint(x: max * 0.5, y: max * 0.65))
        bezierPath.addLine(to: CGPoint(x: max * 0.9, y: max))
        bezierPath.addLine(to: CGPoint(x: max * 0.5, y: 0))
        bezierPath.close()
        UIColor.blue.setFill()
        bezierPath.fill()
        
        return bezierPath.cgPath
    }
    //FIXME: Initial color must be blue also, but for some reason it doesnt work ><
    // Update the arrow's color and rotation when tracking mode is changed.
    func updateArrowForTrackingMode(mode: MGLUserTrackingMode) {
        guard let arrow = arrow else { return }
        switch mode {
        case .follow:
            arrow.fillColor = hexStringToUIColor(hex: blueColor).cgColor
            arrow.strokeColor = hexStringToUIColor(hex: blueColor).cgColor
        case .none:
            arrow.fillColor = UIColor.clear.cgColor
            arrow.strokeColor = UIColor.black.cgColor
        default:
            arrow.fillColor = UIColor.clear.cgColor
            arrow.strokeColor = UIColor.black.cgColor
        }
    
        layoutIfNeeded()
    }
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}



