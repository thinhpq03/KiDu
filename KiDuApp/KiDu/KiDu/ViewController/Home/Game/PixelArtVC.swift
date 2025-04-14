//
//  PixelArtVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 28/3/25.
//

import UIKit

class PixelArtVC: BaseVC {

    let spacing: CGFloat = isIphone ? 15 : 25

    @IBOutlet weak var originImage: UIImageView!
    @IBOutlet weak var canvasView: PixelCanvasView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var showBtn: UIButton!
    @IBOutlet weak var clvHeight: NSLayoutConstraint!

    let viewModel = PixelArtViewModel()

    var selectedPaintColor: UIColor?
    var uiImage: UIImage?

    var isShowing: Bool = false {
        didSet {
            originImage.isHidden = !isShowing
            showBtn.setImage(isShowing ? UIImage(named: "show") : UIImage(named: "hide"), for: .normal)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCLV()
        setupViews()
        setupGestureRecognizers()
    }

    func setupCLV() {
        collectionView.register(ColorPaletteCell.nibClass, forCellWithReuseIdentifier: ColorPaletteCell.cellId)
        collectionView.dataSource = self
        collectionView.delegate = self
        canvasView.backgroundColor = .white

        clvHeight.constant = isIphone ? 80 : 150
    }

    func setupViews() {
        guard let image = uiImage else { return }
        originImage.image = image
        isShowing = false

        let grid = viewModel.createPixelGrid(from: image, rows: 35, cols: 35)
        canvasView.pixelGrid = grid
        viewModel.extractColorGroups(from: grid)
        selectedPaintColor = viewModel.sortedColorGroups.first?.originalColor

        viewModel.applyGrayScaleToPixelGrid()
        canvasView.pixelGrid = viewModel.pixelGrid
    }

    func setupGestureRecognizers() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCanvasTap(_:)))
        canvasView.addGestureRecognizer(tapGesture)

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCanvasPan(_:)))
        canvasView.addGestureRecognizer(panGesture)
    }

    @objc func handleCanvasTap(_ gesture: UITapGestureRecognizer) {
        applyPaint(at: gesture.location(in: canvasView))
    }

    @objc func handleCanvasPan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: canvasView)
        applyPaint(at: location)
    }

    func applyPaint(at location: CGPoint) {
        let pixelGrid = viewModel.pixelGrid
        guard !pixelGrid.isEmpty else { return }
        let numRows = pixelGrid.count
        let numCols = pixelGrid[0].count
        let cellWidth = canvasView.bounds.width / CGFloat(numCols)
        let cellHeight = canvasView.bounds.height / CGFloat(numRows)
        let col = Int(location.x / cellWidth)
        let row = Int(location.y / cellHeight)

        guard row >= 0, row < numRows, col >= 0, col < numCols, let selectedColor = selectedPaintColor else {
            return
        }

        viewModel.pixelGrid[row][col].color = selectedColor
        canvasView.pixelGrid = viewModel.pixelGrid
    }

    func saveImageToFileManager() {
        guard let image = canvasView.capture(), let folderURL = FileManagerService.shared.RelaxFolder() else {
            self.view.showMsg("Fail to save image")
            return
        }
        saveImage(image: image, folderURL: folderURL)
    }

    @IBAction func replay(_ sender: Any) {
        viewModel.applyGrayScaleToPixelGrid()
        canvasView.pixelGrid = viewModel.pixelGrid
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

extension PixelArtVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.sortedColorGroups.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorPaletteCell.cellId,
                                                      for: indexPath) as! ColorPaletteCell
        let group = viewModel.sortedColorGroups[indexPath.item]
        cell.colorView.backgroundColor = group.originalColor
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let group = viewModel.sortedColorGroups[indexPath.item]
        selectedPaintColor = group.originalColor
    }
}

extension PixelArtVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = collectionView.frame.height - (spacing * 2)
        return CGSize(width: height, height: height)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
}

