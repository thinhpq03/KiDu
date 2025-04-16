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
