//
//  Story.swift
//  FastChinese
//
//  Created by iakalann on 07/10/2024.
//

import Foundation

struct Story: Codable, Equatable, Hashable {
    let id: UUID
    var briefLatestStorySummary: String
    let difficulty: Difficulty
    let language: Language
    let title: String
    var chapters: [Chapter]
    var currentChapterIndex = 0
    var lastUpdated: Date

    init(briefLatestStorySummary: String,
         difficulty: Difficulty,
         language: Language,
         title: String,
         chapters: [Chapter],
         currentChapterIndex: Int = 0,
         lastUpdated: Date = .now) {
        self.id = UUID()
        self.briefLatestStorySummary = briefLatestStorySummary
        self.difficulty = difficulty
        self.language = language
        self.title = title
        self.chapters = chapters
        self.currentChapterIndex = currentChapterIndex
        self.lastUpdated = lastUpdated
    }

    // Custom decoder to assign default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.briefLatestStorySummary = try container.decode(String.self, forKey: .briefLatestStorySummary)
        self.difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        self.language = try container.decode(Language.self, forKey: .language)
        self.title = try container.decode(String.self, forKey: .title)
        self.chapters = (try? container.decode([Chapter].self, forKey: .chapters)) ?? []
        self.currentChapterIndex = (try? container.decode(Int.self, forKey: .currentChapterIndex)) ?? 0
        self.lastUpdated = (try? container.decode(Date.self, forKey: .lastUpdated)) ?? .now
    }
}
