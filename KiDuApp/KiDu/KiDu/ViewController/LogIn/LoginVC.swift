//
//  LoginVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 21/3/25.
//

import UIKit
import FirebaseAuth
import Lottie
import GoogleSignIn
import FirebaseCore
import FBSDKLoginKit

class LoginVC: BaseVC {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var login: LottieAnimationView!
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet var views: [UIView]!

    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = Auth.auth().currentUser {
            print("User already logged in: \(user.email ?? "No Email")")
        }
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

        login.loopMode = .loop
        login.animationSpeed = 1
        login.play()

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    //MARK: - Objc

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    //MARK: - Action

    @IBAction func loginClick(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "Email and password can not be empty.")
            return
        }

        guard isValidEmail(email) else {
            showAlert(message: "Email not valid. Please try again.")
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                self.showAlert(message: "Login not successfully: \(error.localizedDescription)")
                return
            } else {
                let vc = CustomTabBarController()
                self.navigationController?.pushViewController(vc, animated: true)
                print("Successfully login: \(authResult?.user.email ?? "")")
            }
        }
    }

    @IBAction func forgotPasswordClick(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(message: "Please enter email to reset password.")
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                self.showAlert(message: "Reset password not successfully: \(error.localizedDescription)")
            } else {
                self.showAlert(message: "An email has been sent to \(email).")
            }
        }
    }

    @IBAction func signUpClick(_ sender: Any) {
        let signUpVC = SignUpVC()
        signUpVC.onSignUpSuccess = { [weak self] email, password in
            self?.emailTextField.text = email
            self?.passwordTextField.text = password
        }
        self.navigationController?.pushViewController(signUpVC, animated: true)
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
                print("Successfully signed in with Facebook: \(authResult?.user.email ?? "")")
                let vc = CustomTabBarController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
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
                print("Successfully signed in with Google: \(authResult?.user.email ?? "")")
                let vc = CustomTabBarController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

}
