//
//  PomodoroVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 27/3/25.
//

import UIKit
import AVFAudio

class PomodoroVC: BaseVC, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet var timePicker: UIPickerView!
    @IBOutlet var startBtn: UIButton!
    @IBOutlet var timeLabel: UILabel!

    let minutes = Array(0...45)
    let seconds = Array(0...59)

    var isStarting: Bool = false {
        didSet {
            if isStarting {
                self.startBtn.setTitle("Stop", for: .normal)
            } else {
                self.startBtn.setTitle("Start", for: .normal)
            }
        }
    }

    var timer: Timer?
    var remainingSeconds: Int = 0
    var audioPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
    }

    func setUpView() {
        startBtn.layer.cornerRadius = 15

        timePicker.delegate = self
        timePicker.dataSource = self
        timePicker.translatesAutoresizingMaskIntoConstraints = false

        timeLabel.isHidden = true

        timePicker.selectRow(25, inComponent: 0, animated: false)
        timePicker.selectRow(0, inComponent: 1, animated: false)
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func startClick(_ sender: Any) {
        isStarting.toggle()

        if isStarting {
            let selectedMinute = minutes[timePicker.selectedRow(inComponent: 0)]
            let selectedSecond = seconds[timePicker.selectedRow(inComponent: 1)]
            remainingSeconds = selectedMinute * 60 + selectedSecond

            timeLabel.text = formatTime(remainingSeconds)
            timeLabel.isHidden = false
            timePicker.isHidden = true

            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        } else {
            stopTimer()
            timeLabel.isHidden = true
            timePicker.isHidden = false
        }
    }

    @objc func updateTimer() {
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            timeLabel.text = formatTime(remainingSeconds)
        } else {
            stopTimer()
            playSound()

            timePicker.isHidden = false
            timeLabel.isHidden = true
            isStarting = false
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func playSound() {
        if let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Fail call ting")
            }
        }
    }

    func Popins(size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size)
    }

    // MARK: - UIPickerView DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? minutes.count : seconds.count
    }

    // MARK: - UIPickerView Delegate
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 80
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        let titleData = component == 0 ? String(format: "%02d", minutes[row]) : String(format: "%02d", seconds[row])

        if row == pickerView.selectedRow(inComponent: component) {
            label.font = Popins(size: 50)
            label.textColor = UIColor.white
        } else {
            label.font = Popins(size: 30)
            label.textColor = UIColor.white.withAlphaComponent(0.5)
        }

        label.text = titleData
        label.textAlignment = .center
        return label
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadAllComponents()
    }
}
