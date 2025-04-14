//
//  ImageCell.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 2/4/25.
//

import UIKit

class ImageCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        img.layer.cornerRadius = 10
    }

}
