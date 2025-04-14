//
//  PixelArtViewModel.swift
//  TUANNM_MV_2538
//
//  Created by Phạm Quý Thịnh on 28/3/25.
//


import UIKit

class PixelArtViewModel {
    
    // MARK: - Data Storage
    var pixelGrid: [[Pixel]] = []
    var colorGroups: [Int: ColorGroup] = [:]
    var sortedColorGroups: [ColorGroup] = []
    
    // MARK: - Public Methods
    
    /// Tạo lưới pixel từ ảnh với số hàng và cột cho trước
    func createPixelGrid(from image: UIImage, rows: Int, cols: Int) -> [[Pixel]] {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: cols, height: rows), false, 1)
        image.draw(in: CGRect(x: 0, y: 0, width: cols, height: rows))
        let pixelatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = pixelatedImage?.cgImage else { return [] }
        let width = cgImage.width
        let height = cgImage.height
        
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let bitsPerComponent = 8
        var pixelData = [UInt8](repeating: 0, count: width * height * 4)
        
        guard let context = CGContext(data: &pixelData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return [] }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var grid = [[Pixel]]()
        var colorToGroup: [String: Int] = [:]
        var currentGroupId = 1
        
        for y in 0..<height {
            var rowPixels = [Pixel]()
            for x in 0..<width {
                let index = (y * width + x) * 4
                let r = CGFloat(pixelData[index]) / 255.0
                let g = CGFloat(pixelData[index+1]) / 255.0
                let b = CGFloat(pixelData[index+2]) / 255.0
                let a = CGFloat(pixelData[index+3]) / 255.0
                
                let paletteColor = UIColor(red: r, green: g, blue: b, alpha: a)
                // Lượng tử hóa màu với ngưỡng riêng cho near-white
                let quantizedColor = paletteColor.quantizedRGB(quantizationValue: 64, nearWhiteQuantizationValue: 16)
                let hex = quantizedColor.toHexString()
                let groupId: Int
                if let existed = colorToGroup[hex] {
                    groupId = existed
                } else {
                    groupId = currentGroupId
                    colorToGroup[hex] = currentGroupId
                    currentGroupId += 1
                }
                let pixel = Pixel(paletteColor: paletteColor, color: paletteColor, groupId: groupId)
                rowPixels.append(pixel)
            }
            grid.append(rowPixels)
        }
        
        self.pixelGrid = grid
        return grid
    }
    
    /// Gom nhóm màu từ lưới pixel và cập nhật danh sách nhóm màu
    func extractColorGroups(from grid: [[Pixel]]) {
        colorGroups = [:]
        for row in grid {
            for pixel in row {
                if colorGroups[pixel.groupId] == nil {
                    let group = ColorGroup(groupId: pixel.groupId,
                                           originalColor: pixel.paletteColor,
                                           currentColor: pixel.paletteColor)
                    colorGroups[pixel.groupId] = group
                }
            }
        }
        sortedColorGroups = colorGroups.keys.sorted().compactMap { colorGroups[$0] }
    }
    
    /// Chuyển đổi màu gốc sang một trong các mức xám
    func quantizedGray(from original: UIColor) -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard original.getRed(&r, green: &g, blue: &b, alpha: &a) else { return original }
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        if luminance >= 0.8 {
            return UIColor(white: 1.0, alpha: a)
        } else if luminance >= 0.6 {
            return UIColor(white: 0.8, alpha: a)
        } else if luminance >= 0.4 {
            return UIColor(white: 0.6, alpha: a)
        } else {
            return UIColor(white: 0.4, alpha: a)
        }
    }
    
    /// Cập nhật lưới pixel để chuyển sang chế độ xám
    func applyGrayScaleToPixelGrid() {
        for i in 0..<pixelGrid.count {
            for j in 0..<pixelGrid[i].count {
                pixelGrid[i][j].color = quantizedGray(from: pixelGrid[i][j].paletteColor)
            }
        }
    }
}
