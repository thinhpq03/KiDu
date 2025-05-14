//
//  SignUpVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 21/3/25.
//

import UIKit
import FirebaseAuth
import Lottie
import FirebaseCore
import GoogleSignIn
import FBSDKLoginKit

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

    @IBAction func google(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            showAlert(message: "Google Sign-In configuration error.")
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(message: "Google Sign-In failed: \(error.localizedDescription)")
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.showAlert(message: "Google Sign-In token error.")
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showAlert(message: "Firebase authentication failed: \(error.localizedDescription)")
                    return
                }
                print("Successfully signed up with Google: \(authResult?.user.email ?? "")")
                self.view.showMsg("Account created successfully!")
                self.onSignUpSuccess?(authResult?.user.email ?? "", "")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    @IBAction func facebook(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert(message: "Facebook Login failed: \(error.localizedDescription)")
                return
            }

            guard let result = result, !result.isCancelled else {
                self.showAlert(message: "Facebook Login cancelled.")
                return
            }

            guard let accessToken = AccessToken.current?.tokenString else {
                self.showAlert(message: "Facebook token error.")
                return
            }

            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken)

            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.showAlert(message: "Firebase authentication failed: \(error.localizedDescription)")
                    return
                }
                print("Successfully signed up with Facebook: \(authResult?.user.email ?? "")")
                self.view.showMsg("Account created successfully!")
                self.onSignUpSuccess?(authResult?.user.email ?? "", "")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
