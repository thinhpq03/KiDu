//
//  TopPicVC.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 27/3/25.
//

import UIKit

class TopPicVC: BaseVC {

    let cell: CGFloat = isIphone ? 1 : 2
    let spacing: CGFloat = isIphone ? 15 : 30
    let padding: CGFloat = isIphone ? 30 : 45

    @IBOutlet weak var topPicCLV: UICollectionView!

    var vocabularyData: [String: [Vocabulary]] = [:]
    var topics: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        topPicCLV.register(TopPicCell.nibClass, forCellWithReuseIdentifier: TopPicCell.cellId)
        topPicCLV.delegate = self
        topPicCLV.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTopicsFromJSON()
    }

    func loadTopicsFromJSON() {
        guard let fileUrl = Bundle.main.url(forResource: "Word", withExtension: "json") else {
            print("Không tìm thấy file JSON")
            return
        }

        do {
            let data = try Data(contentsOf: fileUrl)
            vocabularyData = try JSONDecoder().decode([String: [Vocabulary]].self, from: data)
            topics = Array(vocabularyData.keys).sorted()
            topPicCLV.reloadData()
        } catch {
            print("Lỗi load JSON: \(error)")
        }
    }

    @IBAction func back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension TopPicVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return topics.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopPicCell.cellId, for: indexPath) as! TopPicCell
        let topic = topics[indexPath.item]
        cell.configure(with: topic)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let topic = topics[indexPath.item]
        if let allWords = vocabularyData[topic] {
            // Xáo trộn danh sách từ vựng
            let shuffledWords = allWords.shuffled()

            // Chọn 10 từ ngẫu nhiên (hoặc tất cả nếu ít hơn 10)
            let selectedWords = allWords.count >= 10 ? Array(shuffledWords.prefix(10)) : shuffledWords

            let vc = FillBlankVC()
            vc.vocabularies = Array(selectedWords) // Truyền mảng từ vựng
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension TopPicVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - padding * 2 - (cell - 1) * spacing) / cell
        let height: CGFloat = width * 160 / 380
        return CGSize(width: width, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: padding, left: padding, bottom: padding * 2.5, right: padding)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
}
