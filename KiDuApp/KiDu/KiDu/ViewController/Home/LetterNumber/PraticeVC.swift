//
//  PraticeVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 26/3/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

enum TypePratice {
    case letter
    case number
}

class PraticeVC: BaseVC {

    let padding: CGFloat = isIphone ? 10 : 15
    let spacing: CGFloat = isIphone ? 10 : 15

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
        loadLearningProgress()
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

    // MARK: - Load & Update Learning Progress from Firebase

    func loadLearningProgress() {
        guard let user = Auth.auth().currentUser else { return }
        let docRef = Firestore.firestore().collection("users").document(user.uid)
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error loading learning progress: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                let data = document.data() ?? [:]
                self.learnedItems = data["learnedItems"] as? [String] ?? []
                self.letterNumberCLV.reloadData()
            }
        }
    }

    func updateLearningProgress(with newItem: String) {
        guard let user = Auth.auth().currentUser else { return }
        let docRef = Firestore.firestore().collection("users").document(user.uid)
        docRef.updateData(["learnedItems": FieldValue.arrayUnion([newItem])]) { error in
            if let error = error {
                print("Error updating learning progress: \(error.localizedDescription)")
            } else {
                if !self.learnedItems.contains(newItem) {
                    self.learnedItems.append(newItem)
                }
                self.letterNumberCLV.reloadData()
            }
        }
    }
}

// MARK: - UICollectionView Delegate & DataSource

extension PraticeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return type == .letter ? letters.count : numbers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: LetterNumber = collectionView.dequeueReusableCell(withReuseIdentifier: LetterNumber.cellId, for: indexPath) as! LetterNumber
        let item = type == .letter ? letters[indexPath.row] : numbers[indexPath.row]
        cell.image.image = UIImage(named: item)

        if self.learnedItems.contains(item) {
            cell.backgroundColor = UIColor(hex: "FFF0DB")
        } else {
            cell.backgroundColor = UIColor.white
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = type == .letter ? letters[indexPath.row] : numbers[indexPath.row]
        updateLearningProgress(with: item)
        let vc = WriteVC()
        vc.writeName = type == .letter ? letters[indexPath.row] : numbers[indexPath.row]
        vc.type = type
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PraticeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if type == .letter {
            let width = floor((collectionView.frame.width - padding - spacing * (4 - 1)) / 4)
            let height = floor((collectionView.frame.height - padding * 2 - spacing * (7 - 1)) / 7)
            return CGSize(width: width, height: height)
        }
        let width = floor((collectionView.frame.width - padding - spacing * (4 - 1)) / 4)
        let height = floor((collectionView.frame.height - padding * 2 - spacing * (4 - 1)) / 4)
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
