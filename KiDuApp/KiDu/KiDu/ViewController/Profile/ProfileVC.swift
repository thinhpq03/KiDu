//
//  ProfileVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 14/4/25.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileVC: BaseVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var signOutBtn: UIButton!

    var selectedAvatarImage: UIImage?

    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupAvatarTap()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
        loadUserProfile()
    }

    func setupView() {
        avatar.layer.cornerRadius = 50
        signOutBtn.layer.cornerRadius = 20
    }

    func setupAvatarTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatar.addGestureRecognizer(tapGesture)
        avatar.isUserInteractionEnabled = true
    }

    func loadUserProfile() {
        guard let user = Auth.auth().currentUser else { return }

        emailTxt.text = user.email

        if let displayName = user.displayName, !displayName.isEmpty {
            nameTxt.text = displayName
        } else if let email = user.email {
            nameTxt.text = email.components(separatedBy: "@").first
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
                        self.nameTxt.text = displayName
                    }
                }
            }
        }
    }

    func logoutUser() {
        do {
            try Auth.auth().signOut()
            let welcomeVC = WelcomeVC()
            welcomeVC.modalPresentationStyle = .fullScreen
            self.navigationController?.setViewControllers([welcomeVC], animated: true)
            print("Logout successfully.")
        } catch let error {
            print("Logout error: \(error.localizedDescription)")
        }
    }

    @objc func avatarTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true)
    }

    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        if let image = info[.originalImage] as? UIImage {
            selectedAvatarImage = image
            self.avatar.image = image
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    @IBAction func saveProfile(_ sender: Any) {
        guard let user = Auth.auth().currentUser else { return }

        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = nameTxt.text ?? ""
        changeRequest.commitChanges { error in
            if let error = error {
                print("Error updating auth profile: \(error.localizedDescription)")
            } else {
                print("Auth profile updated successfully.")
            }
        }

        var updateData: [String: Any] = ["displayName": nameTxt.text ?? ""]
        if let newImage = selectedAvatarImage,
           let imageData = newImage.jpegData(compressionQuality: 0.8) {
            let base64String = imageData.base64EncodedString()
            updateData["avatar"] = base64String
        }

        db.collection("users").document(user.uid).setData(updateData, merge: true) { error in
            if let error = error {
                print("Error updating Firestore profile: \(error.localizedDescription)")
                self.view.showMsg("Error update profile")
            } else {
                self.view.showMsg("Update profile successfully.")
            }
        }
    }

    @IBAction func signOut(_ sender: Any) {
        logoutUser()
    }
}
