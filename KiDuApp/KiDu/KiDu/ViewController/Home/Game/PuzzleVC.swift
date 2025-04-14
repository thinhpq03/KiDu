//
//  PuzzleVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 3/4/25.
//

import UIKit

class PuzzleVC: BaseVC {
    let spacing: CGFloat = isIphone ? 10 : 20
    let padding: CGFloat = isIphone ? 15 : 30

    @IBOutlet weak var puzzleView: UIView!
    @IBOutlet weak var originImage: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var showBtn: UIButton!
    @IBOutlet weak var clvHeight: NSLayoutConstraint!

    var uiImage: UIImage?
    private var viewModel: PuzzleViewModel!
    private var selectedIndices: Set<Int> = []

    var isShowing: Bool = false {
        didSet {
            originImage.isHidden = !isShowing
            if isShowing {
                puzzleView.bringSubviewToFront(originImage)
            }
            showBtn.setImage(isShowing ? UIImage(named: "show") : UIImage(named: "hide"), for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupViews()
        setupCLV()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }

    func setupViewModel() {
        guard let image = uiImage else { return }
        viewModel = PuzzleViewModel(image: image, rows: 4, columns: 4, tabRadius: 15)
        viewModel.shufflePieces()
    }

    func setupCLV() {
        collectionView.register(PuzzleCell.nibClass, forCellWithReuseIdentifier: PuzzleCell.cellId)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func setupViews() {
        guard let image = uiImage else { return }
        originImage.image = image
        isShowing = false
        if isIphone {
            clvHeight.constant = 100
        } else {
            clvHeight.constant = 200
        }
    }

    private func calculateGridCenters() -> [[CGPoint]] {
        let gridWidth = puzzleView.frame.width / CGFloat(viewModel.columns)
        let gridHeight = puzzleView.frame.height / CGFloat(viewModel.rows)
        var centers: [[CGPoint]] = []

        for i in 0..<viewModel.rows {
            var rowCenters: [CGPoint] = []
            for j in 0..<viewModel.columns {
                let centerX = (CGFloat(j) + 0.5) * gridWidth
                let centerY = (CGFloat(i) + 0.5) * gridHeight
                rowCenters.append(CGPoint(x: centerX, y: centerY))
            }
            centers.append(rowCenters)
        }
        return centers
    }

    func saveImageToFileManager() {
        guard let image = puzzleView.capture(), let folderURL = FileManagerService.shared.RelaxFolder() else {
            self.view.showMsg("Fail to save image")
            return
        }
        saveImage(image: image, folderURL: folderURL)
    }

    @IBAction func replay(_ sender: Any) {
        for subview in puzzleView.subviews {
            if subview is UIImageView && subview != originImage {
                subview.removeFromSuperview()
            }
        }
        selectedIndices.removeAll()
        viewModel.shufflePieces()
        collectionView.reloadData()
    }

    @IBAction func isShow(_ sender: Any) {
        isShowing.toggle()
    }

    @IBAction func save(_ sender: Any) {
        saveImageToFileManager()
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension PuzzleVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.pieces.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PuzzleCell.cellId, for: indexPath) as! PuzzleCell
        let piece = viewModel.pieces[indexPath.item]
        cell.configure(with: piece.image)
        cell.isHidden = selectedIndices.contains(indexPath.item)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !selectedIndices.contains(indexPath.item) else { return }

        selectedIndices.insert(indexPath.item)
        collectionView.reloadItems(at: [indexPath])

        let piece = viewModel.pieces[indexPath.item]

        let imageView = UIImageView(image: piece.image)
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        let scale = puzzleView.frame.width / viewModel.originalImage.size.width
        let pieceImageSize = piece.image.size
        let pieceWidth = pieceImageSize.width * scale
        let pieceHeight = pieceImageSize.height * scale
        imageView.frame = CGRect(x: 0, y: 0, width: pieceWidth, height: pieceHeight)

        imageView.center = CGPoint(x: puzzleView.bounds.midX, y: puzzleView.bounds.midY)

        let gridWidth = puzzleView.frame.width / CGFloat(viewModel.columns)
        let gridHeight = puzzleView.frame.height / CGFloat(viewModel.rows)
        let correctOrigin = CGPoint(
            x: CGFloat(piece.column) * gridWidth + piece.offsetX * scale,
            y: CGFloat(piece.row) * gridHeight + piece.offsetY * scale
        )
        imageView.accessibilityHint = "\(correctOrigin.x),\(correctOrigin.y)"
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        imageView.addGestureRecognizer(panGesture)
        puzzleView.addSubview(imageView)
    }

}

extension PuzzleVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.height - (padding * 2)
        return CGSize(width: height, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
}

extension PuzzleVC {
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let pieceView = gesture.view as? UIImageView else { return }
        let translation = gesture.translation(in: puzzleView)
        var newCenter = CGPoint(
            x: pieceView.center.x + translation.x,
            y: pieceView.center.y + translation.y
        )

        let minX = pieceView.frame.width / 2
        let maxX = puzzleView.frame.width - pieceView.frame.width / 2
        let minY = pieceView.frame.height / 2
        let maxY = puzzleView.frame.height - pieceView.frame.height / 2
        newCenter.x = max(minX, min(newCenter.x, maxX))
        newCenter.y = max(minY, min(newCenter.y, maxY))
        pieceView.center = newCenter
        gesture.setTranslation(.zero, in: puzzleView)

        if gesture.state == .ended {
            let correctOriginStr = pieceView.accessibilityHint?.split(separator: ",")
            guard let correctX = Double(correctOriginStr?[0] ?? ""),
                  let correctY = Double(correctOriginStr?[1] ?? "") else { return }
            let correctOrigin = CGPoint(x: correctX, y: correctY)

            let distance = hypot(pieceView.frame.origin.x - correctOrigin.x, pieceView.frame.origin.y - correctOrigin.y)
            if distance < 20 {
                pieceView.frame.origin = correctOrigin
                pieceView.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.2) {
                    pieceView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                } completion: { _ in
                    UIView.animate(withDuration: 0.2) {
                        pieceView.transform = .identity
                    }
                }
            }
        }
    }
}
