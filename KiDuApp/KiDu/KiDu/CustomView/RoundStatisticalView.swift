//
//  ArcView.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 25/3/25.
//


import UIKit

class RoundStatisticalView: UIView {

    public let foregroundLayer = CAShapeLayer()
    public let backgroundLayer = CAShapeLayer()

    var progress: CGFloat = 0 {
        didSet {
            setNeedsLayout()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }

    private func setupLayers() {
        // Setup background layer
        backgroundLayer.lineWidth = 8
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = UIColor.init(hex: "D0EFFF", alpha: 1).cgColor
        backgroundLayer.lineCap = .round
        layer.addSublayer(backgroundLayer)

        // Setup foreground layer
        foregroundLayer.lineWidth = 8
        foregroundLayer.fillColor = UIColor.clear.cgColor
        foregroundLayer.strokeColor = UIColor.init(hex: "F9A545").cgColor
        foregroundLayer.lineCap = .round
        layer.addSublayer(foregroundLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        setupPath()
    }

    private func setupPath() {
        let radius = min(bounds.width, bounds.height) / 2 - foregroundLayer.lineWidth / 2
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)

        let startAngle = CGFloat(-1 * Double.pi / 2)
        let endAngle = CGFloat(3 * Double.pi / 2)

        // Background path
        let backgroundPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        backgroundLayer.path = backgroundPath.cgPath

        // Foreground path
        let foregroundEndAngle = startAngle - progress * (2 * CGFloat.pi)
        let foregroundPath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: foregroundEndAngle, clockwise: false)
        foregroundLayer.path = foregroundPath.cgPath
    }
}
