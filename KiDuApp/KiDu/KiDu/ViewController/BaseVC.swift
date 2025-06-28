//
//  BaseVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 23/3/25.
//

import UIKit
import AVFAudio

public let isIphone: Bool = UIDevice.current.userInterfaceIdiom == .phone

class BaseVC: UIViewController {

    var learnedItems: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.overrideUserInterfaceStyle = .light
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }

    func saveImage(image: UIImage, folderURL: URL) {
        let id = UUID().uuidString
        let imageURL = folderURL.appendingPathComponent("\(id).jpg")

        if let imageData = image.jpegData(compressionQuality: 1.0) {
            do {
                try imageData.write(to: imageURL)
                print("Image saved at: \(imageURL.path)")
                self.view.showMsg("Image saved successfully")
            } catch {
                print("Error saving image: \(error)")
                self.view.showMsg("Error saving image")
            }
        }

    }

    func showCongratulations() {
        let alert = UIAlertController(
            title: "🎉 Well done! 🎉",
            message: "You’ve done an amazing Game!",
            preferredStyle: .alert
        )

        let backAction = UIAlertAction(title: "Back", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(backAction)

        alert.view.translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = NSLayoutConstraint(
            item: alert.view!,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: 240
        )
        alert.view.addConstraint(heightConstraint)

        if let bg = alert.view.subviews.first?.subviews.first?.subviews.first {
            bg.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.9)
            bg.layer.cornerRadius = 20
        }

        if let confettiImage = UIImage(named: "confetti") {
            let iv = UIImageView(image: confettiImage)
            iv.translatesAutoresizingMaskIntoConstraints = false
            iv.contentMode = .scaleAspectFit
            alert.view.addSubview(iv)

            NSLayoutConstraint.activate([
                iv.centerXAnchor.constraint(equalTo: alert.view.centerXAnchor),
                iv.centerYAnchor.constraint(equalTo: alert.view.centerYAnchor),
                iv.widthAnchor.constraint(equalToConstant: 100),
                iv.heightAnchor.constraint(equalToConstant: 100),
            ])
        }

        alert.view.tintColor = UIColor.systemPurple

        present(alert, animated: true) {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }

    func loadImage(from folderURL: URL) -> [UIImage]? {
        var images: [UIImage] = []
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: folderURL, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                if let image = UIImage(contentsOfFile: fileURL.path) {
                    images.append(image)
                }
            }
            return images
        } catch {
            print("Error loading images: \(error)")
            return nil
        }
    }

}
