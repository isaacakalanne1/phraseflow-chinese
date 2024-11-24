//
//  Story.swift
//  FastChinese
//
//  Created by iakalann on 07/10/2024.
//

import Foundation

struct Story: Codable, Equatable, Hashable {
    let id: UUID
    var briefLatestStorySummaryinEnglish: String
    let difficulty: Difficulty
    let language: Language
    let title: String
    var chapters: [Chapter]
    var setting: StorySetting
    var currentChapterIndex = 0
    var lastUpdated: Date

    init(briefLatestStorySummaryinEnglish: String,
         difficulty: Difficulty,
         language: Language,
         title: String,
         chapters: [Chapter],
         setting: StorySetting,
         currentChapterIndex: Int = 0,
         lastUpdated: Date = .now) {
        self.id = UUID()
        self.briefLatestStorySummaryinEnglish = briefLatestStorySummaryinEnglish
        self.difficulty = difficulty
        self.language = language
        self.title = title
        self.chapters = chapters
        self.setting = setting
        self.currentChapterIndex = currentChapterIndex
        self.lastUpdated = lastUpdated
    }

    // Custom decoder to assign default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.briefLatestStorySummaryinEnglish = try container.decode(String.self, forKey: .briefLatestStorySummaryinEnglish)
        self.difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        self.language = try container.decode(Language.self, forKey: .language)
        self.title = try container.decode(String.self, forKey: .title)
        self.chapters = (try? container.decode([Chapter].self, forKey: .chapters)) ?? []
        self.setting = (try? container.decode(StorySetting.self, forKey: .setting)) ?? .futuristic
        self.currentChapterIndex = (try? container.decode(Int.self, forKey: .currentChapterIndex)) ?? 0
        self.lastUpdated = (try? container.decode(Date.self, forKey: .lastUpdated)) ?? .now
    }
}
