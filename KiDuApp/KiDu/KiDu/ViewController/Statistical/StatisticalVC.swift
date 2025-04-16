//
//  StatisticalVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 14/4/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class StatisticalVC: UIViewController {

    @IBOutlet var monChart: UIView!
    @IBOutlet var tueChart: UIView!
    @IBOutlet var wedChart: UIView!
    @IBOutlet var thuChart: UIView!
    @IBOutlet var friChart: UIView!
    @IBOutlet var satChart: UIView!
    @IBOutlet var sunChart: UIView!
    @IBOutlet var stackChart: UIStackView!

    @IBOutlet var viewsChart: [UIView]!
    @IBOutlet var views: [UIView]!
    @IBOutlet var viewsbg: [UIView]!

    @IBOutlet var monHeight: NSLayoutConstraint!
    @IBOutlet var tueHeight: NSLayoutConstraint!
    @IBOutlet var wedHeight: NSLayoutConstraint!
    @IBOutlet var thuHeight: NSLayoutConstraint!
    @IBOutlet var friHeight: NSLayoutConstraint!
    @IBOutlet var satHeight: NSLayoutConstraint!
    @IBOutlet var sunHeight: NSLayoutConstraint!

    @IBOutlet var chart: RoundStatisticalView!
    @IBOutlet var perLb: UILabel!

    //Test Time
    let maxHours: CGFloat = 0.5
    let db = Firestore.firestore()

    var weeklyStudyData: [String: TimeInterval] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpView()
        loadStudyLogsAndUpdateCharts()
    }

    func setUpView() {
        viewsChart.forEach {
            $0.layer.cornerRadius = 10
            $0.backgroundColor = UIColor(hex: "F6903C")
        }

        views.forEach {
            $0.layer.cornerRadius = 10
            $0.backgroundColor = UIColor(hex: "F6903C", alpha: 0.2)
        }

        viewsbg.forEach {
            $0.layer.cornerRadius = 15
        }
    }

    // MARK: - Load Study Logs Từ Firestore

    func loadStudyLogsAndUpdateCharts() {
        guard let weekRange = getStartAndEndOfWeek(containing: Date()) else { return }
        loadStudyLogsForWeek(weekRange: weekRange) { [weak self] dailyStudyTime in
            DispatchQueue.main.async {
                self?.weeklyStudyData = dailyStudyTime
                self?.logWeeklyData(for: weekRange)
                self?.updateChartHeightsForStudy()
            }
        }
    }

    func logWeeklyData(for weekRange: (startOfWeek: Date, endOfWeek: Date)) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var currentDay = weekRange.startOfWeek
        let calendar = Calendar.current
        print("Weekly Study Data (ordered Monday -> Sunday):")
        for _ in 0..<7 {
            let dayKey = dateFormatter.string(from: currentDay)
            let totalTime = weeklyStudyData[dayKey] ?? 0
            print("\(dayKey): \(totalTime)")
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay)!
        }
    }

    func loadStudyLogsForWeek(weekRange: (startOfWeek: Date, endOfWeek: Date), completion: @escaping ([String: TimeInterval]) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion([:])
            return
        }
        let studyLogsRef = db.collection("users").document(currentUser.uid).collection("studyLogs")
        studyLogsRef.getDocuments { snapshot, error in
            var dailyStudyTime: [String: TimeInterval] = [:]
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"

            var calendar = Calendar.current
            calendar.firstWeekday = 2
            var currentDay = weekRange.startOfWeek
            var weekDays: [String] = []
            while currentDay <= weekRange.endOfWeek {
                let dayString = dateFormatter.string(from: currentDay)
                weekDays.append(dayString)
                currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay)!
            }
            for day in weekDays {
                dailyStudyTime[day] = 0
            }

            if let error = error {
                print("Error fetching study logs: \(error.localizedDescription)")
                completion(dailyStudyTime)
                return
            }

            if let documents = snapshot?.documents {
                print("Fetched documents count: \(documents.count)")
                for document in documents {
                    print("DocID: \(document.documentID) -> Data: \(document.data())")
                }
                for document in documents {
                    let docId = document.documentID
                    if weekDays.contains(docId) {
                        let data = document.data()
                        let totalTime = data.reduce(0.0) { (result, element) -> Double in
                            let (key, value) = element
                            if key.hasPrefix("activities.") {
                                if let doubleVal = value as? Double {
                                    return result + doubleVal
                                } else if let numVal = value as? NSNumber {
                                    return result + numVal.doubleValue
                                }
                            }
                            return result
                        }
                        dailyStudyTime[docId] = totalTime
                    }
                }
            }
            completion(dailyStudyTime)
        }
    }

    // MARK: - Cập Nhật Chart

    func updateChartHeightsForStudy() {
        print("StackChart Height: \(chartMaxHeight())")

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let weekRange = getStartAndEndOfWeek(containing: Date()) else { return }
        let calendar = Calendar.current
        var currentDay = weekRange.startOfWeek

        var dailyRates: [CGFloat] = []
        let maxStudySeconds = maxHours * 3600.0

        for _ in 0..<7 {
            let dayKey = dateFormatter.string(from: currentDay)
            let totalTime = weeklyStudyData[dayKey] ?? 0
            var rate = CGFloat(totalTime) / CGFloat(maxStudySeconds)
            if rate > 1 { rate = 1 }
            dailyRates.append(rate)
            currentDay = calendar.date(byAdding: .day, value: 1, to: currentDay)!
        }

        let chartConstraints = [monHeight, tueHeight, wedHeight, thuHeight, friHeight, satHeight, sunHeight]
        for (index, rate) in dailyRates.enumerated() {
            if index < chartConstraints.count {
                let newHeight = rate * chartMaxHeight()
                setChartHeight(chartConstraints[index]!, height: newHeight)
            }
        }

        let todayKey = dateFormatter.string(from: Date())
        let todayTime = weeklyStudyData[todayKey] ?? 0
        var todayRate = CGFloat(todayTime) / CGFloat(maxStudySeconds)
        if todayRate > 1 { todayRate = 1 }
        chart.progress = todayRate
        perLb.text = "\(Int(todayRate * 100))%"
    }

    // MARK: - Helper Functions

    func getStartAndEndOfWeek(containing date: Date) -> (startOfWeek: Date, endOfWeek: Date)? {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return nil
        }
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        return (startOfWeek, endOfWeek)
    }

    func chartMaxHeight() -> CGFloat {
        return stackChart.frame.height
    }

    func setChartHeight(_ chartConstraint: NSLayoutConstraint, height: CGFloat) {
        chartConstraint.constant = height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}
