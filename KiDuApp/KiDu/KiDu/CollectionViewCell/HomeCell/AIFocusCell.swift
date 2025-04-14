//
//  AIFocusCell.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 25/3/25.
//

import UIKit

class AIFocusCell: UICollectionViewCell {

    @IBOutlet weak var actionBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        actionBtn.layer.cornerRadius = 17.5
        actionBtn.layer.borderColor = UIColor(hex: "F9A545").cgColor
        actionBtn.layer.borderWidth = 1
        self.layer.cornerRadius = 25
        self.clipsToBounds = true
    }

}
