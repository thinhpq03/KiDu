//
//  DrawCell.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 25/3/25.
//

import UIKit

class DrawCell: UICollectionViewCell {

    @IBOutlet weak var actionBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        actionBtn.layer.cornerRadius = 17.5
        actionBtn.layer.borderColor = UIColor(hex: "F9A545").cgColor
        actionBtn.layer.borderWidth = 1
    }

}
