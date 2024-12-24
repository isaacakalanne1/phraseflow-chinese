//
//  ChapterResponse.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 29/10/2024.
//

import Foundation

struct ChapterResponse: Codable {
    let titleOfNovel: String?
    let chapterNumberAndTitle: String?
    let briefLatestStorySummary: String
    let sentences: [Sentence]

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.titleOfNovel = (try? container.decode(String.self, forKey: .titleOfNovel)) ?? nil
        self.chapterNumberAndTitle = (try? container.decode(String.self, forKey: .chapterNumberAndTitle)) ?? nil
        self.briefLatestStorySummary = try container.decode(String.self, forKey: .briefLatestStorySummary)
        self.sentences = try container.decode([Sentence].self, forKey: .sentences)
    }
}
