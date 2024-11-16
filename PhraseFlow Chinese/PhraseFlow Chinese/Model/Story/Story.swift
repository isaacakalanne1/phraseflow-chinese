//
//  Story.swift
//  FastChinese
//
//  Created by iakalann on 07/10/2024.
//

import Foundation

struct Story: Codable, Equatable, Hashable {
    let id: UUID
    var latestStorySummary: String
    let difficulty: Difficulty
    let title: String
    var chapters: [Chapter]
    var currentChapterIndex = 0

    init(latestStorySummary: String,
         difficulty: Difficulty,
         title: String,
         chapters: [Chapter],
         currentChapterIndex: Int = 0) {
        self.id = UUID()
        self.latestStorySummary = latestStorySummary
        self.difficulty = difficulty
        self.title = title
        self.chapters = chapters
        self.currentChapterIndex = currentChapterIndex
    }

    // Custom decoder to assign default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.latestStorySummary = try container.decode(String.self, forKey: .latestStorySummary)
        self.difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        self.title = try container.decode(String.self, forKey: .title)
        self.chapters = (try? container.decode([Chapter].self, forKey: .chapters)) ?? []
        self.currentChapterIndex = (try? container.decode(Int.self, forKey: .currentChapterIndex)) ?? 0
    }
}
