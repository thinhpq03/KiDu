//
//  CustomTabBarView.swift
//  TUANNM_MV_2509
//
//  Created by Phạm Quý Thịnh on 7/1/25.
//

import UIKit
import Foundation

class CustomTabBarView: UIView {

    var items: [UITabBarItem] = []
    var selectedItem: UITabBarItem? {
        didSet {
            guard let item = selectedItem else { return }
            for button in buttons {
                button.isSelected = (button.tag == item.tag)
                updateButtonAppearance(button)
            }
        }
    }

    var onTabSelected: ((Int) -> Void)?

    private var buttons: [UIButton] = []
    private let selectedImages: [UIImage?] = [
        UIImage(named: "home"),
        UIImage(named: "statistical"),
        UIImage(named: "profile")
    ]
    private let unselectedImages: [UIImage?] = [
        UIImage(named: "home_in"),
        UIImage(named: "statistical_in"),
        UIImage(named: "profile_in")
    ]

    init(items: [UITabBarItem]) {
        self.items = items
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .white
        layer.cornerRadius = 0
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false

        for (index, item) in items.enumerated() {
            let button = UIButton(type: .custom)
            button.setImage(unselectedImages[index] ?? UIImage(), for: .normal)
            button.setTitle(item.title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(UIColor.init(hex: "#ED802D"), for: .selected)
            button.tag = index

            button.addTarget(self, action: #selector(tabBarButtonTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            addSubview(button)
        }

        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func updateButtonAppearance(_ button: UIButton) {
        let index = button.tag
        if button.isSelected {
            button.setImage(selectedImages[index] ?? UIImage(), for: .selected)
        } else {
            button.setImage(unselectedImages[index] ?? UIImage(), for: .normal)
        }
    }

    @objc private func tabBarButtonTapped(_ sender: UIButton) {
        let selectedItem = items[sender.tag]
        self.selectedItem = selectedItem
        onTabSelected?(sender.tag)
    }
}
