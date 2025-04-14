//
//  ChooseLetterNumberVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 26/3/25.
//

import UIKit

class ChooseLetterNumberVC: UIViewController {

    @IBOutlet var backgroundViews: [UIView]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backgroundViews.forEach { $0.layer.cornerRadius = 20 }
    }

    @IBAction func letter(_ sender: Any) {
        let praticeVC = PraticeVC()
        praticeVC.type = .letter
        self.navigationController?.pushViewController(praticeVC, animated: true)
    }
    
    @IBAction func number(_ sender: Any) {
        let praticeVC = PraticeVC()
        praticeVC.type = .number
        self.navigationController?.pushViewController(praticeVC, animated: true)
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
