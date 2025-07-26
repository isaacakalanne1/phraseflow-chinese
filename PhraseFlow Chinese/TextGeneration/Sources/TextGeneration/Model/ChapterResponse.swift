//
//  ChapterResponse.swift
//  FlowTale
//
//  Created by iakalann on 29/10/2024.
//

import Foundation

public struct ChapterResponse: Codable {
    let titleOfNovel: String?
    public let chapterNumberAndTitle: String?
    let briefLatestStorySummary: String
    public let sentences: [Sentence]

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.titleOfNovel = (try? container.decode(String.self, forKey: .titleOfNovel)) ?? nil
        self.chapterNumberAndTitle = (try? container.decode(String.self, forKey: .chapterNumberAndTitle)) ?? nil
        self.briefLatestStorySummary = try container.decode(String.self, forKey: .briefLatestStorySummary)
        self.sentences = try container.decode([Sentence].self, forKey: .sentences)
    }
}
