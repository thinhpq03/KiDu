//
//  WriteVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 27/3/25.
//

import UIKit
import PencilKit

class WriteVC: BaseVC, PKCanvasViewDelegate {

    @IBOutlet weak var smallImage: UIImageView!
    @IBOutlet weak var bigImage: UIImageView!
    @IBOutlet weak var practiveView: UIView!
    @IBOutlet weak var uperLowerBtn: UIButton!

    var writeName: String?
    var isUperCase: Bool = true {
        didSet {
            setUpBigImage()
        }
    }
    var type: TypePratice = .letter

    private var canvasView: PKCanvasView!
    private var toolPicker: PKToolPicker!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCanvasView()
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()
        toolPicker.overrideUserInterfaceStyle = .light
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        toolPicker.setVisible(false, forFirstResponder: canvasView)
    }

    func setupView() {
        guard let name = writeName else { return }
        smallImage.image = UIImage(named: name)

        switch type {
            case .letter:
                uperLowerBtn.isHidden = false
                isUperCase = true
            case .number:
                uperLowerBtn.isHidden = true
        }
        setUpBigImage()
    }

    func setUpBigImage() {
        guard var name = writeName else { return }
        name = name.lowercased()
        var bigName: String = ""

        switch type {
            case .letter:
                if isUperCase {
                    bigName = "up_\(name)"
                } else {
                    bigName = "low_\(name)"
                }
            case .number:
                bigName = "pratice_\(name)"
        }
        bigImage.image = UIImage(named: bigName)
    }

    func setupCanvasView() {
        canvasView = PKCanvasView(frame: practiveView.bounds)
        canvasView.delegate = self
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
        practiveView.addSubview(canvasView)

        if #available(iOS 14.0, *) {
            toolPicker = PKToolPicker()
        } else {
            toolPicker = PKToolPicker.shared(for: self.view.window!)
        }
        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(true, forFirstResponder: canvasView)
        canvasView.becomeFirstResponder()

        let defaultTool = PKInkingTool(.crayon, color: UIColor(hex: "F9A545"), width: 40)
        toolPicker.selectedTool = defaultTool
    }

    @IBAction func swapLowUp(_ sender: Any) {
        isUperCase.toggle()
        canvasView.drawing = PKDrawing()
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension WriteVC {
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
    }
}
