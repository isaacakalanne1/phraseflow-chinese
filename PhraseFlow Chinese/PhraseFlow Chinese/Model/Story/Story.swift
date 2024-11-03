//
//  Story.swift
//  FastChinese
//
//  Created by iakalann on 07/10/2024.
//

import Foundation

struct Story: Codable, Equatable, Hashable {
    let id: UUID
    let storyOverview: String
    var latestStorySummary: String
    let difficulty: Difficulty
    let title: String
    let description: String
    var chapters: [Chapter]
    var currentChapterIndex = 0

    init(storyOverview: String,
         latestStorySummary: String,
         difficulty: Difficulty,
         title: String,
         description: String,
         chapters: [Chapter],
         currentChapterIndex: Int = 0) {
        self.id = UUID()
        self.storyOverview = storyOverview
        self.latestStorySummary = latestStorySummary
        self.difficulty = difficulty
        self.title = title
        self.description = description
        self.chapters = chapters
        self.currentChapterIndex = currentChapterIndex
    }

    // Custom decoder to assign default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.storyOverview = try container.decode(String.self, forKey: .storyOverview)
        self.latestStorySummary = try container.decode(String.self, forKey: .latestStorySummary)
        self.difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)

        self.chapters = (try? container.decode([Chapter].self, forKey: .chapters)) ?? []

        self.currentChapterIndex = (try? container.decode(Int.self, forKey: .currentChapterIndex)) ?? 0
    }
}
