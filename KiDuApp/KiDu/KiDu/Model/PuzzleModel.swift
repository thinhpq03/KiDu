//
//  PuzzleModel.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 3/4/25.
//

import Foundation
import UIKit

enum SideType {
    case flat
    case tab
    case blank
}

struct PieceSides {
    let top: SideType
    let bottom: SideType
    let left: SideType
    let right: SideType
}

struct PuzzlePiece {
    let image: UIImage
    let correctFrame: CGRect
    let tabRadius: CGFloat
    let offsetX: CGFloat
    let offsetY: CGFloat
    let row: Int
    let column: Int
}
