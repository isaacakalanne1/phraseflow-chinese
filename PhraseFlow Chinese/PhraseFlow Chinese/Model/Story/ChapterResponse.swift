//
//  ChapterResponse.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 29/10/2024.
//

import Foundation

struct ChapterResponse: Codable {
    let titleOfNovel: String?
    let latestStorySummaryInEnglish: String
    let sentences: [Sentence]

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.titleOfNovel = (try? container.decode(String.self, forKey: .titleOfNovel)) ?? nil
        self.latestStorySummaryInEnglish = try container.decode(String.self, forKey: .latestStorySummaryInEnglish)
        self.sentences = try container.decode([Sentence].self, forKey: .sentences)
    }
}
