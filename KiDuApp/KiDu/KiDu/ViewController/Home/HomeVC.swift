//
//  HomeVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 25/3/25.
//

import UIKit
import Lottie
import FirebaseAuth
import FirebaseFirestore

class HomeVC: BaseVC {

    let cell: CGFloat = isIphone ? 1 : 2
    let spacing: CGFloat = isIphone ? 15 : 30
    let padding: CGFloat = isIphone ? 30 : 45

    let layouts: [String] = [
        LetterNumberCell.cellId,
        PomodorosCell.cellId,
        FillBlankCell.cellId,
        AIFocusCell.cellId,
        RelaxCell.cellId
    ]

    @IBOutlet weak var arlertView: UIView!
    @IBOutlet weak var progressLb: UILabel!
    @IBOutlet weak var statisticalView: RoundStatisticalView!
    @IBOutlet weak var beeAnimation: LottieAnimationView!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var homeCLV: UICollectionView!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameLB: UILabel!

    let db = Firestore.firestore()

    var selectedCellStartTime: Date?
    var selectedCellName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        setupContinueView()
        setupCLV()
        loadUserProfile()
        loadLearningProgress()
    }

    func setupContinueView() {
        arlertView.layer.cornerRadius = 30
        arlertView.layer.shadowColor = UIColor.black.cgColor
        arlertView.layer.shadowOpacity = 0.2
        arlertView.layer.shadowOffset = .zero
        arlertView.layer.shadowRadius = 8

        beeAnimation.animationSpeed = 1
        beeAnimation.loopMode = .loop
        beeAnimation.play()

        continueBtn.layer.cornerRadius = 22.5
    }

    func setupCLV() {
        homeCLV.register(LetterNumberCell.nibClass, forCellWithReuseIdentifier: LetterNumberCell.cellId)
        homeCLV.register(PomodorosCell.nibClass, forCellWithReuseIdentifier: PomodorosCell.cellId)
        homeCLV.register(FillBlankCell.nibClass, forCellWithReuseIdentifier: FillBlankCell.cellId)
        homeCLV.register(AIFocusCell.nibClass, forCellWithReuseIdentifier: AIFocusCell.cellId)
        homeCLV.register(RelaxCell.nibClass, forCellWithReuseIdentifier: RelaxCell.cellId)

        homeCLV.delegate = self
        homeCLV.dataSource = self
    }

    func loadUserProfile() {
        guard let user = Auth.auth().currentUser else { return }
        avatar.layer.cornerRadius = avatar.frame.width / 2
        if let displayName = user.displayName, !displayName.isEmpty {
            nameLB.text = displayName
        } else if let email = user.email {
            nameLB.text = email.components(separatedBy: "@").first
        }

        let docRef = db.collection("users").document(user.uid)
        docRef.getDocument { document, error in
            if let error = error {
                print("Error fetching user document: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                let data = document.data() ?? [:]
                if let avatarBase64 = data["avatar"] as? String, !avatarBase64.isEmpty {
                    if let imageData = Data(base64Encoded: avatarBase64), let image = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            self.avatar.image = image
                        }
                    }
                }
                if let displayName = data["displayName"] as? String {
                    DispatchQueue.main.async {
                        self.nameLB.text = displayName
                    }
                }
            }
        }
    }

    func loadLearningProgress() {
        guard let user = Auth.auth().currentUser else { return }
        let docRef = db.collection("users").document(user.uid)
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error loading learning progress: \(error.localizedDescription)")
            } else if let document = document, document.exists {
                let data = document.data() ?? [:]
                self.learnedItems = data["learnedItems"] as? [String] ?? []
                self.updateProgressPercentage()
            }
        }
    }

    func updateProgressPercentage() {
        let totalCount = 40
        let progressPercent = (Double(self.learnedItems.count) / Double(totalCount)) * 100
        progressLb.text = "\(Int(progressPercent))%"
        statisticalView.progress = progressPercent / 100
    }

    func saveStudyTime() {
        guard let startTime = selectedCellStartTime,
              let cellName = selectedCellName,
              let user = Auth.auth().currentUser else { return }

        let endTime = Date()
        let elapsedTime = endTime.timeIntervalSince(startTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDate = dateFormatter.string(from: Date())

        let studyLogRef = db.collection("users")
            .document(user.uid)
            .collection("studyLogs")
            .document(todayDate)

        studyLogRef.setData([
            "activities.\(cellName)": FieldValue.increment(elapsedTime)
        ], merge: true) { error in
            if let error = error {
                print("Error saving study time: \(error.localizedDescription)")
            } else {
                print("Study time for \(cellName) saved successfully.")
            }
        }
        selectedCellStartTime = nil
        selectedCellName = nil
    }

    @IBAction func continueClick(_ sender: Any) {
        let chooseVC = ChooseLetterNumberVC()
        chooseVC.onDismiss = saveStudyTime
        navigationController?.pushViewController(chooseVC, animated: true)
    }
    
}

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let layout = layouts[indexPath.row]
        switch layout {
            case LetterNumberCell.cellId:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LetterNumberCell.cellId, for: indexPath) as! LetterNumberCell
                return cell
            case PomodorosCell.cellId:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PomodorosCell.cellId, for: indexPath) as! PomodorosCell
                return cell
            case FillBlankCell.cellId:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FillBlankCell.cellId, for: indexPath) as! FillBlankCell
                return cell
            case AIFocusCell.cellId:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AIFocusCell.cellId, for: indexPath) as! AIFocusCell
                return cell
            case RelaxCell.cellId:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RelaxCell.cellId, for: indexPath) as! RelaxCell
                return cell
            default:
                fatalError("Unknown cell type")
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layout = layouts[indexPath.row]
        selectedCellStartTime = Date()
        selectedCellName = layout

        switch layout {
            case LetterNumberCell.cellId:
                let chooseVC = ChooseLetterNumberVC()
                chooseVC.onDismiss = saveStudyTime
                navigationController?.pushViewController(chooseVC, animated: true)
            case PomodorosCell.cellId:
                let pomodoroVC = PomodoroVC()
                pomodoroVC.onDismiss = saveStudyTime
                navigationController?.pushViewController(pomodoroVC, animated: true)
            case FillBlankCell.cellId:
                let vc = TopPicVC()
                vc.onDismiss = saveStudyTime
                self.navigationController?.pushViewController(vc, animated: true)
            case AIFocusCell.cellId:
                let camereVC = CameraVC()
                camereVC.onDismiss = saveStudyTime
                navigationController?.pushViewController(camereVC, animated: true)
            case RelaxCell.cellId:
                let vc = SelectGameVC()
                vc.onDismiss = saveStudyTime
                navigationController?.pushViewController(vc, animated: true)
            default:
                return
        }
    }

}

extension HomeVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - padding * 2 - (cell - 1) * spacing) / cell
        let height: CGFloat = width * 160 / 380
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding, left: padding, bottom: padding * 2.5, right: padding)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
}
