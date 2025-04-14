//
//  ColorPaletteCell.swift
//  TestPixel
//
//  Created by Phạm Quý Thịnh on 28/3/25.
//

import UIKit

class ColorPaletteCell: UICollectionViewCell {

    @IBOutlet weak var colorView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Cài đặt giao diện mặc định cho cell
        colorView.layer.cornerRadius = 8
        colorView.layer.borderWidth = 1
        colorView.layer.borderColor = UIColor.gray.cgColor
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                colorView.layer.borderWidth = 3
                colorView.layer.borderColor = UIColor.init(hex: "F9A545").cgColor
                UIView.animate(withDuration: 0.2) {
                    self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }
            } else {
                colorView.layer.borderWidth = 1
                colorView.layer.borderColor = UIColor.gray.cgColor
                UIView.animate(withDuration: 0.2) {
                    self.transform = CGAffineTransform.identity
                }
            }
        }
    }
}
