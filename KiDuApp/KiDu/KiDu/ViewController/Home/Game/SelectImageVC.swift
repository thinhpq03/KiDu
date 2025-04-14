//
//  SelectImageVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 28/3/25.
//

import UIKit

class SelectImageVC: UIViewController {

    let cell: CGFloat = isIphone ? 3 : 5
    let spacing: CGFloat = isIphone ? 10 : 20
    let padding: CGFloat = isIphone ? 24 : 36

    @IBOutlet weak var imageCLV: UICollectionView!

    var type: GameType = .puzzle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCLV()
    }

    func setupCLV() {
        imageCLV.register(ImageCell.nibClass, forCellWithReuseIdentifier: ImageCell.cellId)
        imageCLV.register(AddCell.nibClass, forCellWithReuseIdentifier: AddCell.cellId)
        imageCLV.delegate = self
        imageCLV.dataSource = self
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SelectImageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        let chosenImage = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
        guard let image = chosenImage else { return }
        switch type {
            case .puzzle:
                let puzzleVC = PuzzleVC()
                puzzleVC.uiImage = image
                self.navigationController?.pushViewController(puzzleVC, animated: true)
            case .pixel:
                let pixelArtVC = PixelArtVC()
                pixelArtVC.uiImage = image
                self.navigationController?.pushViewController(pixelArtVC, animated: true)
        }

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension SelectImageVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 15
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddCell.cellId, for: indexPath) as! AddCell
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.cellId, for: indexPath) as! ImageCell
            cell.img.image = UIImage(named: "Game\(indexPath.item)")
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 0 {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        } else {
            switch type {
                case .puzzle:
                    let puzzleVC = PuzzleVC()
                    puzzleVC.uiImage = UIImage(named: "Game\(indexPath.item)")
                    self.navigationController?.pushViewController(puzzleVC, animated: true)
                case .pixel:
                    let pixelArtVC = PixelArtVC()
                    pixelArtVC.uiImage = UIImage(named: "Game\(indexPath.item)")
                    self.navigationController?.pushViewController(pixelArtVC, animated: true)
            }
        }
    }

}

extension SelectImageVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var width: CGFloat = (collectionView.frame.width - spacing * (cell - 1) - padding * 2) / cell
        width = floor(width)
        let height: CGFloat = width * 155 / 125
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }
}
