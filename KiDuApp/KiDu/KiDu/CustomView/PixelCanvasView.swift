//
//  PixelCanvasView.swift
//  TUANNM_MV_2538
//
//  Created by Phạm Quý Thịnh on 28/3/25.
//


import UIKit

class PixelCanvasView: UIView {
    var pixelGrid: [[Pixel]] = [] {
        didSet { setNeedsDisplay() }
    }

    override func draw(_ rect: CGRect) {
        guard !pixelGrid.isEmpty else { return }
        let numRows = pixelGrid.count
        let numCols = pixelGrid[0].count
        let cellWidth = rect.width / CGFloat(numCols)
        let cellHeight = rect.height / CGFloat(numRows)
        for (rowIndex, row) in pixelGrid.enumerated() {
            for (colIndex, pixel) in row.enumerated() {
                let cellRect = CGRect(x: CGFloat(colIndex) * cellWidth,
                                      y: CGFloat(rowIndex) * cellHeight,
                                      width: cellWidth,
                                      height: cellHeight)
                let fillPath = UIBezierPath(rect: cellRect)
                pixel.color.setFill()
                fillPath.fill()
                let borderPath = UIBezierPath(rect: cellRect)
                UIColor.black.setStroke()
                borderPath.lineWidth = 1.0
                borderPath.stroke()
            }
        }
    }
}

extension UIColor {
    
    func toGrayscale() -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            let gray = (0.299 * r + 0.587 * g + 0.114 * b)
            return UIColor(white: gray, alpha: a)
        }
        return self
    }

    func quantizedRGB(quantizationValue: Int = 64, nearWhiteQuantizationValue: Int = 16) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard self.getRed(&r, green: &g, blue: &b, alpha: &a) else { return self }

        let luminance = 0.299 * r + 0.587 * g + 0.114 * b

        let qValue = luminance > 0.9 ? nearWhiteQuantizationValue : quantizationValue

        let quantize: (CGFloat) -> CGFloat = { channel in
            let c = Int(channel * 255)
            let half = qValue / 2
            var newVal = ((c + half) / qValue) * qValue
            if newVal > 255 { newVal = 255 }
            return CGFloat(newVal) / 255.0
        }
        return UIColor(red: quantize(r), green: quantize(g), blue: quantize(b), alpha: a)
    }

    func toHexString() -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        let rInt = Int(r * 255), gInt = Int(g * 255), bInt = Int(b * 255)
        return String(format: "#%02X%02X%02X", rInt, gInt, bInt)
    }
}
