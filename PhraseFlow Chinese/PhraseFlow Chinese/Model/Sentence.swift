//
//  Phrase.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 07/09/2024.
//

import Foundation
import SwiftWhisper

struct CodableSegment: Equatable, Codable {
    public let startTime: Int
    public let endTime: Int
    public let text: String
}

struct Sentence: Identifiable, Codable, Equatable {
    var id = UUID() // Use a UUID for easy identification
    let mandarin: String
    let pinyin: String
    let english: String

    var audioData: Data? = nil
    var characterSegments: [CodableSegment] = []

    var splitMandarin: [String]? {
        let words = NSMutableArray()
        JiebaWrapper()
            .objcJiebaCut(mandarin, toWords: words)
        return words as? [String]
    }

    func word(atIndex index: Int) -> String? {
        var characterIndex = -1
        guard let mandarinList = splitMandarin else { return nil }
        for word in mandarinList {
            characterIndex += word.count
            if characterIndex >= index {
                return word
            }
        }
        return nil
    }

    var category: PhraseCategory = .short

    // Custom decoder to assign default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mandarin = try container.decode(String.self, forKey: .mandarin)
        self.pinyin = try container.decode(String.self, forKey: .pinyin)
        self.english = try container.decode(String.self, forKey: .english)

        self.audioData = nil
        self.characterSegments = []
        self.category = .short // Or provide a category based on context
    }

    init(mandarin: String,
         pinyin: String,
         english: String,
         category: PhraseCategory) {
        self.mandarin = mandarin
        self.pinyin = pinyin
        self.english = english
        self.category = category
    }
}
