//
//  Story.swift
//  FastChinese
//
//  Created by iakalann on 07/10/2024.
//

import Foundation

struct Story: Codable, Equatable, Hashable {
    let storyOverview: String
    let chapterSummaryList: [String]
    let difficulty: Difficulty
    let title: String
    let description: String
    var chapters: [Chapter]
    var currentChapterIndex = 0

    // Custom decoder to assign default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.storyOverview = try container.decode(String.self, forKey: .storyOverview)
        self.chapterSummaryList = try container.decode([String].self, forKey: .chapterSummaryList)
        self.difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)

        self.chapters = (try? container.decode([Chapter].self, forKey: .chapters)) ?? []

        self.currentChapterIndex = try container.decode(Int.self, forKey: .currentChapterIndex)
    }
}
