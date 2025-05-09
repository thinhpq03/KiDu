//
//  FillBlankVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 3/4/25.
//

import UIKit
import FirebaseFirestore

class FillBlankVC: UIViewController, UITextFieldDelegate {

    // Danh sách từ vựng từ Firebase
    var vocabularies: [Vocabulary] = []
    // Chỉ số từ hiện tại
    var currentIndex: Int = 0
    // Số từ điền đúng
    var correctCount: Int = 0

    var puzzle: String = ""
    var missingIndices: [Int] = []
    var missingLetters: [Character] = []
    var missingTextFields: [UITextField] = []

    @IBOutlet weak var puzzleStackView: UIStackView!
    @IBOutlet weak var pronuncLb: UILabel!
    @IBOutlet weak var currentLb: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFirebase()
    }

    // Thiết lập kết nối Firebase và lấy dữ liệu
    func setupFirebase() {
        let db = Firestore.firestore()
        db.collection("vocabulary").document("Animals").collection("words").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                return
            }
            self.vocabularies = querySnapshot?.documents.compactMap { doc -> Vocabulary? in
                let data = doc.data()
                let word = data["word"] as? String ?? ""
                let pronunciation = data["pronunciation"] as? String ?? ""
                let meaning = data["meaning"] as? String ?? ""
                return Vocabulary(word: word, pronunciation: pronunciation, meaning: meaning)
            } ?? []

            // Lấy 10 từ đầu tiên (hoặc ít hơn nếu không đủ)
            self.vocabularies = Array(self.vocabularies.prefix(10))
            if !self.vocabularies.isEmpty {
                self.setupPuzzle()
            } else {
                print("Error: No vocabularies found in Firebase.")
            }
        }
    }

    // Thiết lập câu đố cho từ hiện tại
    func setupPuzzle() {
        // Kiểm tra nếu đã hết từ
        guard currentIndex < vocabularies.count else {
            showFinalResult()
            return
        }

        let vocabulary = vocabularies[currentIndex]
        let word = vocabulary.word
        let pronunciation = vocabulary.pronunciation // Lấy cách phát âm
        pronuncLb.text = pronunciation // Hiển thị cách phát âm
        currentLb.text = "Current: \(currentIndex + 1)/\(vocabularies.count)"

        let result = createPuzzle(for: word)
        puzzle = result.puzzle
        missingIndices = result.missingIndices
        missingLetters = result.missingLetters

        // Xóa giao diện cũ
        puzzleStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        missingTextFields = []

        // Tạo giao diện mới với textfield bo góc
        for char in puzzle {
            if char == "_" {
                let textField = UITextField()
                textField.textAlignment = .center
                textField.borderStyle = .roundedRect
                textField.layer.cornerRadius = 8
                textField.layer.borderWidth = 1
                textField.layer.borderColor = UIColor.gray.cgColor
                textField.placeholder = "_"
                textField.attributedPlaceholder = NSAttributedString(string: "_", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
                textField.delegate = self
                textField.textColor = .black
                textField.backgroundColor = .clear
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .none
                puzzleStackView.addArrangedSubview(textField)
                missingTextFields.append(textField)
            } else {
                let label = UILabel()
                label.text = String(char)
                label.textAlignment = .center
                label.textColor = .black
                puzzleStackView.addArrangedSubview(label)
            }
        }

        puzzleStackView.distribution = .fillEqually
    }

    // Tạo câu đố với các chữ cái bị ẩn
    func createPuzzle(for word: String) -> (puzzle: String, missingIndices: [Int], missingLetters: [Character]) {
        let characters = Array(word)
        let count = characters.count
        var omitCount: Int = 0

        if count < 5 {
            omitCount = 1
        } else {
            omitCount = Int.random(in: 2...min(3, count - 2))
        }

        var indices = Set<Int>()
        while indices.count < omitCount {
            let randomIndex = Int.random(in: 1..<(count - 1))
            indices.insert(randomIndex)
        }

        let sortedIndices = Array(indices).sorted()
        var missingChars: [Character] = []
        var puzzleChars = characters

        for index in sortedIndices {
            missingChars.append(characters[index])
            puzzleChars[index] = "_"
        }
        return (String(puzzleChars), sortedIndices, missingChars)
    }

    // Kiểm tra câu trả lời
    @IBAction func checkAnswer(_ sender: Any) {
        var isCorrect = true

        for i in 0..<missingTextFields.count {
            let textField = missingTextFields[i]
            if let text = textField.text, text.count == 1, text.lowercased() == String(missingLetters[i]).lowercased() {
                textField.backgroundColor = .green
            } else {
                isCorrect = false
                textField.backgroundColor = .red
            }
        }

        if isCorrect {
            correctCount += 1
            self.view.showMsg("Chúc mừng! Bạn đã điền đúng từ \"\(vocabularies[currentIndex].word)\".")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.moveToNextWord()
            }
        } else {
            self.view.showMsg("Chưa đúng! Có một số chữ cái chưa chính xác. Hãy thử lại!")
        }
    }

    func moveToNextWord() {
        currentIndex += 1
        if currentIndex < vocabularies.count {
            setupPuzzle()
        } else {
            showFinalResult()
        }
    }

    func showFinalResult() {
        let alert = UIAlertController(title: "Hoàn thành", message: "Bạn đã hoàn thành \(vocabularies.count) từ. Số từ đúng: \(correctCount)/\(vocabularies.count)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Quay lại", style: .default, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }

    // Giới hạn nhập 1 ký tự cho mỗi text field
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return newText.count <= 1
    }

    // Nút quay lại
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
