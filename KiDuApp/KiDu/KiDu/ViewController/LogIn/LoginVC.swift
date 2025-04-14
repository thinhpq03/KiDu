//
//  LoginVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 21/3/25.
//

import UIKit
import FirebaseAuth
import Lottie

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
            navigateToMainScreen()
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

    private func navigateToMainScreen() {
        print("logined")
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

}
