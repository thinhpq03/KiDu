//
//  PraticeVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 26/3/25.
//

import UIKit

enum TypePratice {
    case letter
    case number
}

class PraticeVC: BaseVC {

    let padding: CGFloat = isIphone ? 10 : 15
    let spacing: CGFloat = isIphone ? 0 : 10

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var letterNumberCLV: UICollectionView!
    
    let letters: [String] = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    let numbers: [String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "%", "*", "+", "-", "!", "#", "$"]

    var type: TypePratice = .letter

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupCLV()
        setupView()
    }

    func setupView() {
        backgroundView.layer.cornerRadius = 40
    }

    func setupCLV() {
        letterNumberCLV.register(LetterNumber.nibClass, forCellWithReuseIdentifier: LetterNumber.cellId)
        letterNumberCLV.delegate = self
        letterNumberCLV.dataSource = self
        letterNumberCLV.reloadData()
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

extension PraticeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return type == .letter ? letters.count : numbers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LetterNumber = collectionView.dequeueReusableCell(withReuseIdentifier: LetterNumber.cellId, for: indexPath) as! LetterNumber
        let namePratice = type == .letter ? letters[indexPath.row] : numbers[indexPath.row]
        cell.image.image = UIImage(named: namePratice)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = WriteVC()
        vc.writeName = type == .letter ? letters[indexPath.row] : numbers[indexPath.row]
        vc.type = type
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PraticeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if type == .letter {
            var width: CGFloat = (collectionView.frame.width - padding * 2 - spacing * (4 - 1)) / 4
            var height: CGFloat = (collectionView.frame.height - padding * 2 - spacing * (7 - 1)) / 7
            width = floor(width)
            height = floor(height)

            return CGSize(width: width, height: height)
        }

        var width: CGFloat = (collectionView.frame.width - padding * 2 - spacing * (4 - 1)) / 4
        var height: CGFloat = (collectionView.frame.height - padding * 2 - spacing * (4 - 1)) / 4
        width = floor(width)
        height = floor(height)
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding, left: padding / 2, bottom: padding, right: padding / 2)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
}
