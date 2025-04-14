//
//  PuzzleCell.swift
//  TUANNM_MV_2538
//
//  Created by Phạm Quý Thịnh on 31/3/25.
//

import UIKit

class PuzzleCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(with image: UIImage) {
        img.image = image
    }

}
