//
//  WelcomeVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 14/11/24.
//

import UIKit
import FirebaseAuth
import Lottie

class WelcomeVC: BaseVC {

    @IBOutlet weak var welcome: LottieAnimationView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let user = Auth.auth().currentUser {
                print("User logged in: \(user.email ?? "Không có email")")
                self.navigateToMainScreen()
            } else {
                print("User not logged in")
                self.navigateToLoginScreen()
            }
        }
    }

    func setupView() {
        welcome.loopMode = .loop
        welcome.animationSpeed = 1
        welcome.play()
    }

    private func navigateToMainScreen() {
        let homeVC = CustomTabBarController()
        self.navigationController?.pushViewController(homeVC, animated: true)
    }

    private func navigateToLoginScreen() {
        let loginVC = LoginVC()
        self.navigationController?.pushViewController(loginVC, animated: true)
    }

}

