//
//  AIFocusVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 27/3/25.
//

import UIKit
import AVFoundation

class AIFocusVC: BaseVC {

    @IBOutlet weak var imageBg: UIView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var detectedLb: UILabel!
    @IBOutlet weak var spellLb: UILabel!
    @IBOutlet var views: [UIView]!

    var detectedText: String?
    var originalImage: UIImage?
    private let synthesizer = AVSpeechSynthesizer()

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        if let detectedText = detectedText {
            displayIPA(for: detectedText)
        }
    }

    func setupView() {
        views.forEach { $0.layer.cornerRadius = 25 }
        imageBg.layer.cornerRadius = 10
        imageBg.clipsToBounds = true
        imageBg.layer.borderWidth = 1
        imageBg.layer.borderColor = UIColor(hex: "F9A545").cgColor

        guard let detectedText = detectedText, let originalImage = originalImage else {
            return
        }

        image.image = originalImage
        detectedLb.text = detectedText.capitalized
    }

    @IBAction func speak(_ sender: Any) {
        guard let text = detectedText else { return }
        speakText(text)
    }

    func speakText(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)

        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_female_en-US_premium") {
            utterance.voice = voice
        }
        else if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-compact") {
            utterance.voice = voice
        }
        else {
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        }

        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        synthesizer.speak(utterance)
    }


    func loadIPADictionary(completion: @escaping ([String: String]) -> Void) {
        let urlString = "https://raw.githubusercontent.com/hoanganhtuan95ptit/ipa-dict/master/data/en_UK.txt"
        guard let url = URL(string: urlString) else {
            completion([:])
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion([:])
                return
            }
            let content = String(data: data, encoding: .utf8) ?? ""
            let lines = content.split(separator: "\n")
            var dictionary: [String: String] = [:]
            for line in lines {
                let parts = line.split(separator: "\t")
                if parts.count == 2 {
                    let word = String(parts[0]).lowercased()
                    let pronunciation = String(parts[1])
                    dictionary[word] = pronunciation
                }
            }
            completion(dictionary)
        }.resume()
    }

    func displayIPA(for word: String) {
        loadIPADictionary { dictionary in
            let lowercaseWord = word.lowercased()
            if let pronunciation = dictionary[lowercaseWord] {
                DispatchQueue.main.async {
                    self.spellLb.text = pronunciation
                }
            } else {
                DispatchQueue.main.async {
                    self.spellLb.text = ""
                    self.views[1].isHidden = true
                }
            }
        }
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
