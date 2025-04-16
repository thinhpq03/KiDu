//
//  CustomTabBarController.swift
//  Jewelry
//
//  Created by Phạm Quý Thịnh on 13/3/25.
//


import UIKit

class CustomTabBarController: UITabBarController {

    private var customTabBarView: CustomTabBarView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupCustomTabBarView()

        if #available(iOS 17.0, *) {
            traitOverrides.horizontalSizeClass = .compact 
        } else {

        }
    }

    private func setupViewControllers() {
        let homeVC = HomeVC()
        homeVC.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "home"), tag: 0)

        let statistical = StatisticalVC()
        statistical.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "statistical"), tag: 1)

        let profile = ProfileVC()
        profile.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "profile"), tag: 2)

        viewControllers = [homeVC, statistical, profile]
    }

    private func setupCustomTabBarView() {
        let items = tabBar.items ?? []
        customTabBarView = CustomTabBarView(items: items)
        customTabBarView.selectedItem = items.first
        customTabBarView.onTabSelected = { [weak self] index in
            self?.switchToViewController(at: index)
        }
        view.addSubview(customTabBarView)

        NSLayoutConstraint.activate([
            customTabBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            customTabBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            customTabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            customTabBarView.heightAnchor.constraint(equalToConstant: 80)
        ])

        customTabBarView.backgroundColor = UIColor(hex: "FFF0DB")
        customTabBarView.layer.cornerRadius = 40
        tabBar.isHidden = true
    }

    func switchToViewController(at index: Int) {
        selectedIndex = index
        customTabBarView.selectedItem = tabBar.items?[index]
    }
}


