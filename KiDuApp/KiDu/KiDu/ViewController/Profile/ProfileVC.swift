//
//  ProfileVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 14/4/25.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

class ProfileVC: BaseVC, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var nameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var signOutBtn: UIButton!

    var selectedAvatarImage: UIImage?

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
            let nameFromEmail = email.components(separatedBy: "@").first
            nameTxt.text = nameFromEmail
        }

        if let photoURL = user.photoURL {
            URLSession.shared.dataTask(with: photoURL) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.avatar.image = image
                    }
                }
            }.resume()
        } else {
            self.avatar.image = UIImage(named: "placeholder")
        }
    }

    func logoutUser() {
        do {
            try Auth.auth().signOut()
            let welcomeVC = WelcomeVC()
            welcomeVC.modalPresentationStyle = .fullScreen
            self.navigationController?.setViewControllers([welcomeVC], animated: true)
            print("Logout successfuly.")
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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

        if let newImage = selectedAvatarImage {
            guard let imageData = newImage.jpegData(compressionQuality: 0.8) else { return }

            let storageRef = Storage.storage().reference().child("avatars").child("\(user.uid).jpg")
            storageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error upload image: \(error.localizedDescription)")
                    return
                }
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error get download URL: \(error.localizedDescription)")
                        return
                    }

                    if let url = url {
                        changeRequest.photoURL = url
                        changeRequest.commitChanges { error in
                            if let error = error {
                                print("Error update profile: \(error.localizedDescription)")
                                self.view.showMsg("Error update profile")
                            } else {
                                self.view.showMsg("Update profile successfully.")
                            }
                        }
                    }
                }
            }
        } else {
            changeRequest.commitChanges { error in
                if let error = error {
                    print("Lỗi khi cập nhật profile: \(error.localizedDescription)")
                    self.view.showMsg("Error update profile")
                } else {
                    self.view.showMsg("Update profile successfully.")
                }
            }
        }
    }

    @IBAction func signOut(_ sender: Any) {
        logoutUser()
    }
}
