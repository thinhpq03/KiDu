//
//  SignUpVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 21/3/25.
//

import UIKit
import FirebaseAuth
import Lottie

class SignUpVC: BaseVC {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rePasswordTextField: UITextField!
    @IBOutlet weak var signUp: LottieAnimationView!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet var views: [UIView]!
    
    var onSignUpSuccess: ((String, String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
    }

    //MARK: - Func
    func setUpView() {
        views.forEach {
            $0.layer.cornerRadius = 30
        }
        signUpBtn.layer.cornerRadius = 25
        signUp.loopMode = .loop
        signUp.animationSpeed = 1
        signUp.play()
    }

    //MARK: - Action
    @IBAction func signUpClick(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Email and password are required.")
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.handleFirebaseError(error)
                return
            }

            self.view.showMsg("Account created successfully!")
            print("Successfully signed up: \(authResult?.user.email ?? "")")
            self.onSignUpSuccess?(email, password)
            self.navigationController?.popViewController(animated: true)
        }
    }

    private func handleFirebaseError(_ error: Error) {
        let errorCode = AuthErrorCode(rawValue: (error as NSError).code)
        var errorMessage: String = "Error occurred."

        switch errorCode {
            case .invalidEmail:
                errorMessage = "Email not valid."
            case .emailAlreadyInUse:
                errorMessage = "This email is already in use."
            case .weakPassword:
                errorMessage = "Password is too weak. Please use at least 6 characters."
            default:
                errorMessage = error.localizedDescription
        }

        self.showAlert(message: errorMessage)
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
