import UIKit

class PuzzleViewModel {
    let originalImage: UIImage
    let rows: Int
    let columns: Int
    var pieces: [PuzzlePiece] = []
    let tabRadius: CGFloat

    init(image: UIImage, rows: Int, columns: Int, tabRadius: CGFloat = 10.0) {
        let squareImage = cropToSquare(image: image)
        self.originalImage = squareImage
        self.rows = rows
        self.columns = columns
        self.tabRadius = tabRadius
        generatePieces()
    }

    func generatePieces() {
        let baseWidth = originalImage.size.width / CGFloat(columns)
        let baseHeight = originalImage.size.height / CGFloat(rows)

        let H = (0..<rows-1).map { _ in (0..<columns).map { _ in Int.random(in: 0...1) } }
        let V = (0..<rows).map { _ in (0..<columns-1).map { _ in Int.random(in: 0...1) } }

        for i in 0..<rows {
            for j in 0..<columns {
                let top: SideType = i == 0 ? .flat : (H[i-1][j] == 0 ? .blank : .tab)
                let bottom: SideType = i == rows-1 ? .flat : (H[i][j] == 0 ? .tab : .blank)
                let left: SideType = j == 0 ? .flat : (V[i][j-1] == 0 ? .blank : .tab)
                let right: SideType = j == columns-1 ? .flat : (V[i][j] == 0 ? .tab : .blank)

                let sides = PieceSides(top: top, bottom: bottom, left: left, right: right)
                let path = createPiecePath(sides: sides, baseWidth: baseWidth, baseHeight: baseHeight, tabRadius: tabRadius)
                let bounds = path.bounds
                let offsetX = bounds.origin.x
                let offsetY = bounds.origin.y
                let image = createPieceImage(path: path, i: i, j: j, baseWidth: baseWidth, baseHeight: baseHeight, tabRadius: tabRadius)
                let correctFrame = CGRect(x: CGFloat(j) * baseWidth, y: CGFloat(i) * baseHeight, width: baseWidth, height: baseHeight)

                let piece = PuzzlePiece(image: image, correctFrame: correctFrame, tabRadius: tabRadius, offsetX: offsetX, offsetY: offsetY, row: i, column: j)
                pieces.append(piece)
            }
        }
    }

    func createPiecePath(sides: PieceSides, baseWidth: CGFloat, baseHeight: CGFloat, tabRadius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))

        if sides.top == .flat {
            path.addLine(to: CGPoint(x: baseWidth, y: 0))
        } else if sides.top == .tab {
            let controlPoint = CGPoint(x: baseWidth / 2, y: -tabRadius * 1.2)
            path.addLine(to: CGPoint(x: baseWidth / 2 - tabRadius, y: 0))
            path.addQuadCurve(to: CGPoint(x: baseWidth / 2 + tabRadius, y: 0), controlPoint: controlPoint)
            path.addLine(to: CGPoint(x: baseWidth, y: 0))
        } else {
            let controlPoint = CGPoint(x: baseWidth / 2, y: tabRadius * 1.2)
            path.addLine(to: CGPoint(x: baseWidth / 2 - tabRadius, y: 0))
            path.addQuadCurve(to: CGPoint(x: baseWidth / 2 + tabRadius, y: 0), controlPoint: controlPoint)
            path.addLine(to: CGPoint(x: baseWidth, y: 0))
        }

        if sides.right == .flat {
            path.addLine(to: CGPoint(x: baseWidth, y: baseHeight))
        } else if sides.right == .tab {
            let controlPoint = CGPoint(x: baseWidth + tabRadius * 1.2, y: baseHeight / 2)
            path.addLine(to: CGPoint(x: baseWidth, y: baseHeight / 2 - tabRadius))
            path.addQuadCurve(to: CGPoint(x: baseWidth, y: baseHeight / 2 + tabRadius), controlPoint: controlPoint)
            path.addLine(to: CGPoint(x: baseWidth, y: baseHeight))
        } else {
            let controlPoint = CGPoint(x: baseWidth - tabRadius * 1.2, y: baseHeight / 2)
            path.addLine(to: CGPoint(x: baseWidth, y: baseHeight / 2 - tabRadius))
            path.addQuadCurve(to: CGPoint(x: baseWidth, y: baseHeight / 2 + tabRadius), controlPoint: controlPoint)
            path.addLine(to: CGPoint(x: baseWidth, y: baseHeight))
        }

        if sides.bottom == .flat {
            path.addLine(to: CGPoint(x: 0, y: baseHeight))
        } else if sides.bottom == .tab {
            let controlPoint = CGPoint(x: baseWidth / 2, y: baseHeight + tabRadius * 1.2)
            path.addLine(to: CGPoint(x: baseWidth / 2 + tabRadius, y: baseHeight))
            path.addQuadCurve(to: CGPoint(x: baseWidth / 2 - tabRadius, y: baseHeight), controlPoint: controlPoint)
            path.addLine(to: CGPoint(x: 0, y: baseHeight))
        } else {
            let controlPoint = CGPoint(x: baseWidth / 2, y: baseHeight - tabRadius * 1.2)
            path.addLine(to: CGPoint(x: baseWidth / 2 + tabRadius, y: baseHeight))
            path.addQuadCurve(to: CGPoint(x: baseWidth / 2 - tabRadius, y: baseHeight), controlPoint: controlPoint)
            path.addLine(to: CGPoint(x: 0, y: baseHeight))
        }

        if sides.left == .flat {
            path.addLine(to: CGPoint(x: 0, y: 0))
        } else if sides.left == .tab {
            let controlPoint = CGPoint(x: -tabRadius * 1.2, y: baseHeight / 2)
            path.addLine(to: CGPoint(x: 0, y: baseHeight / 2 + tabRadius))
            path.addQuadCurve(to: CGPoint(x: 0, y: baseHeight / 2 - tabRadius), controlPoint: controlPoint)
            path.addLine(to: CGPoint(x: 0, y: 0))
        } else {
            let controlPoint = CGPoint(x: tabRadius * 1.2, y: baseHeight / 2)
            path.addLine(to: CGPoint(x: 0, y: baseHeight / 2 + tabRadius))
            path.addQuadCurve(to: CGPoint(x: 0, y: baseHeight / 2 - tabRadius), controlPoint: controlPoint)
            path.addLine(to: CGPoint(x: 0, y: 0))
        }

        path.close()
        return path
    }

    func createPieceImage(path: UIBezierPath, i: Int, j: Int, baseWidth: CGFloat, baseHeight: CGFloat, tabRadius: CGFloat) -> UIImage {
        let bounds = path.bounds
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        let img = renderer.image { ctx in
            ctx.cgContext.translateBy(x: -bounds.origin.x, y: -bounds.origin.y)
            path.addClip()

            let xOffset = -CGFloat(j) * baseWidth
            let yOffset = -CGFloat(i) * baseHeight

            originalImage.draw(at: CGPoint(x: xOffset, y: yOffset))
        }
        return img
    }

    func shufflePieces() {
        pieces.shuffle()
    }
}

func cropToSquare(image: UIImage) -> UIImage {
    let originalSize = image.size
    let minSide = min(originalSize.width, originalSize.height)
    let cropRect = CGRect(
        x: (originalSize.width - minSide) / 2,
        y: (originalSize.height - minSide) / 2,
        width: minSide,
        height: minSide
    )
    let imageRef = image.cgImage!.cropping(to: cropRect)!
    return UIImage(cgImage: imageRef)
}
