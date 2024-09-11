//
//  Phrase.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 07/09/2024.
//

import Foundation

struct Phrase: Identifiable, Codable, Equatable {
    var id = UUID() // Use a UUID for easy identification
    let mandarin: String
    let pinyin: String
    let english: String

    var audioData: Data? = nil
    var characterTimestamps: [TimeInterval] = []
    var category: PhraseCategory = .short
    var isLearning = false

    // Custom decoder to assign default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mandarin = try container.decode(String.self, forKey: .mandarin)
        self.pinyin = try container.decode(String.self, forKey: .pinyin)
        self.english = try container.decode(String.self, forKey: .english)

        self.audioData = nil
        self.characterTimestamps = []
        self.category = .short // Or provide a category based on context
        self.isLearning = false
    }

    init(mandarin: String,
         pinyin: String,
         english: String,
         category: PhraseCategory,
         isLearning: Bool = false) {
        self.mandarin = mandarin
        self.pinyin = pinyin
        self.english = english
        self.category = category
    }
}
