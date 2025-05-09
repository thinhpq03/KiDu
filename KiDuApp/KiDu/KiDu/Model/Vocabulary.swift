//
//  Vocabulary.swift
//  KiDu
//
//  Created by Phạm Quý Thịnh on 3/4/25.
//


import Foundation

struct Vocabulary {
    let word: String
    let pronunciation: String
    let meaning: String

    init(word: String, pronunciation: String, meaning: String) {
        self.word = word
        self.pronunciation = pronunciation
        self.meaning = meaning
    }
}
