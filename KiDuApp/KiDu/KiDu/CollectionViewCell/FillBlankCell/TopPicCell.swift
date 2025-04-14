//
//  TopPicCell.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 3/4/25.
//

import UIKit

class TopPicCell: UICollectionViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = 20
    }

    func configure(with title: String) {
        name.text = title
        img.image = UIImage(named: title)
    }
}
