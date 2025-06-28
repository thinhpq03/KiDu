//
//  SelectGameVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 3/4/25.
//

import UIKit

enum GameType {
    case puzzle, pixel
}

class SelectGameVC: UIViewController {

    @IBOutlet var views: [UIView]!
    
    var onDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        views.forEach {
            $0.layer.cornerRadius = 10
            $0.layer.borderColor = UIColor(hex: "F9A545").cgColor
            $0.layer.borderWidth = 1
            $0.clipsToBounds = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            onDismiss?()
        }
    }

    @IBAction func gamePuzzle(_ sender: Any) {
        let selectImageVC = SelectImageVC()
        selectImageVC.type = .puzzle
        self.navigationController?.pushViewController(selectImageVC, animated: true)
    }
    
    @IBAction func gamePixel(_ sender: Any) {
        let selectImageVC = SelectImageVC()
        selectImageVC.type = .pixel
        self.navigationController?.pushViewController(selectImageVC, animated: true)
    }
    
    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
