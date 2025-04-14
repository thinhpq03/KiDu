//
//  Pixel.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 28/3/25.
//


import UIKit

struct Pixel {
    var paletteColor: UIColor
    var color: UIColor
    var groupId: Int
}

struct ColorGroup {
    let groupId: Int
    let originalColor: UIColor
    var currentColor: UIColor
}
