//
//  Extension-Font.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 23/3/25.
//

import Foundation
import UIKit


extension UIFont {
    static func NS_B(_ size: CGFloat) -> UIFont? {
        let size = isIphone ? size : size + 6
        return UIFont(name: "NotoSerif-Bold", size: size)
    }
    
    static func NS_R(_ size: CGFloat) -> UIFont? {
        let size = isIphone ? size : size + 6
        return UIFont(name: "NotoSerif-Regular", size: size)
    }

    static func NS_SB(_ size: CGFloat) -> UIFont? {
        let size = isIphone ? size : size + 6
        return UIFont(name: "NotoSerif-SemiBold", size: size)
    }

    static func PP_B(_ size: CGFloat) -> UIFont? {
        let size = isIphone ? size : size + 6
        return UIFont(name: "Poppins-Bold", size: size)
    }

    static func PP_R(_ size: CGFloat) -> UIFont? {
        let size = isIphone ? size : size + 6
        return UIFont(name: "Poppins-Regular", size: size)
    }

    static func PP_SB(_ size: CGFloat) -> UIFont? {
        let size = isIphone ? size : size + 6
        return UIFont(name: "Poppins-SemiBold", size: size)
    }

}
