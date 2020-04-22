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

    // Initializer to create the user tracking mode button
    init(buttonSize: CGFloat) {
        self.buttonSize = buttonSize
        super.init(frame: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize))
        self.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        self.layer.cornerRadius = 4

        let arrow = CAShapeLayer()
        arrow.path = arrowPath()
        arrow.lineWidth = 2
        arrow.lineJoin = CAShapeLayerLineJoin.round
        arrow.bounds = CGRect(x: 0, y: 0, width: buttonSize / 2, height: buttonSize / 2)
        arrow.position = CGPoint(x: buttonSize / 2, y: buttonSize / 2)
        arrow.shouldRasterize = true
        arrow.rasterizationScale = UIScreen.main.scale
        arrow.drawsAsynchronously = true
        self.arrow = arrow

        // Update arrow for initial tracking mode
        updateArrowForTrackingMode(mode: .none)
        layer.addSublayer(self.arrow!)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func arrowPath() -> CGPath {
        let bezierPath = UIBezierPath()
        let max: CGFloat = buttonSize / 2
        bezierPath.move(to: CGPoint(x: max * 0.5, y: 0))
        bezierPath.addLine(to: CGPoint(x: max * 0.1, y: max))
        bezierPath.addLine(to: CGPoint(x: max * 0.5, y: max * 0.65))
        bezierPath.addLine(to: CGPoint(x: max * 0.9, y: max))
        bezierPath.addLine(to: CGPoint(x: max * 0.5, y: 0))
        bezierPath.close()
        return bezierPath.cgPath
    }

    // Update the arrow's color and rotation when tracking mode is changed.
    func updateArrowForTrackingMode(mode: MGLUserTrackingMode) {
        guard let arrow = arrow else { return }
        arrow.fillColor = UIColor.clear.cgColor
        arrow.strokeColor = UIColor.black.cgColor
        layoutIfNeeded()
    }
}
