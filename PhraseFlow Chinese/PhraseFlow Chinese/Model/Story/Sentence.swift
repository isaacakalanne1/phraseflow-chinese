//
//  Sentence.swift
//  FastChinese
//
//  Created by iakalann on 07/09/2024.
//

import Foundation

struct Sentence: Identifiable, Codable, Equatable {
    var id = UUID() // Use a UUID for easy identification
    let mandarin: String
    let pinyin: [String]
    let english: String

    var audioData: Data? = nil

    // Custom decoder to assign default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mandarin = try container.decode(String.self, forKey: .mandarin)
        self.pinyin = try container.decode([String].self, forKey: .pinyin)
        self.english = try container.decode(String.self, forKey: .english)

        self.audioData = nil
    }

    init(mandarin: String,
         pinyin: [String],
         english: String) {
        self.mandarin = mandarin
        self.pinyin = pinyin
        self.english = english
    }
}
