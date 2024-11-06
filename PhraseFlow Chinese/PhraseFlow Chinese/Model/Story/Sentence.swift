//
//  Sentence.swift
//  FastChinese
//
//  Created by iakalann on 07/09/2024.
//

import Foundation

struct Sentence: Codable, Equatable, Hashable {
    let mandarin: String
    let pinyin: [String]
    let english: String
    let speechStyle: SpeechStyle

    // Custom decoder to assign default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.mandarin = try container.decode(String.self, forKey: .mandarin)
        self.pinyin = try container.decode([String].self, forKey: .pinyin)
        self.english = try container.decode(String.self, forKey: .english)
        self.speechStyle = try container.decode(SpeechStyle.self, forKey: .speechStyle)
    }
}
