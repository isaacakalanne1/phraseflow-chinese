//
//  Story.swift
//  FlowTale
//
//  Created by iakalann on 07/10/2024.
//

import Foundation

struct Story: Codable, Equatable, Hashable {
    let id: UUID
    var briefLatestStorySummary: String
    let difficulty: Difficulty
    let language: Language
    var title: String
    var chapters: [Chapter]
    var currentChapterIndex = 0
    var currentSentenceIndex = 0
    var currentPlaybackTime: Double = 0
    var lastUpdated: Date
    var storyPrompt: String

    init(briefLatestStorySummary: String = "",
         difficulty: Difficulty,
         language: Language,
         title: String = "",
         chapters: [Chapter] = [],
         storyPrompt: String,
         currentChapterIndex: Int = 0,
         currentSentenceIndex: Int = 0,
         currentPlaybackTime: Double = 0,
         lastUpdated: Date = .now) {
        self.id = UUID()
        self.briefLatestStorySummary = briefLatestStorySummary
        self.difficulty = difficulty
        self.language = language
        self.title = title
        self.chapters = chapters
        self.currentChapterIndex = currentChapterIndex
        self.currentSentenceIndex = currentSentenceIndex
        self.currentPlaybackTime = currentPlaybackTime
        self.lastUpdated = lastUpdated
        self.storyPrompt = storyPrompt
    }

    // Custom decoder to assign default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.briefLatestStorySummary = try container.decode(String.self, forKey: .briefLatestStorySummary)
        self.difficulty = try container.decode(Difficulty.self, forKey: .difficulty)
        self.language = try container.decode(Language.self, forKey: .language)
        self.title = try container.decode(String.self, forKey: .title)
        self.chapters = (try? container.decode([Chapter].self, forKey: .chapters)) ?? [] // TODO: Improve this code, to avoid running out of memory. Possibly decode chapters one at a time, rather than all chapters at once
        self.currentChapterIndex = (try? container.decode(Int.self, forKey: .currentChapterIndex)) ?? 0
        self.currentSentenceIndex = (try? container.decode(Int.self, forKey: .currentSentenceIndex)) ?? 0
        self.currentPlaybackTime = (try? container.decode(Double.self, forKey: .currentPlaybackTime)) ?? 0
        self.lastUpdated = (try? container.decode(Date.self, forKey: .lastUpdated)) ?? .now
        self.storyPrompt = (try? container.decode(String.self, forKey: .storyPrompt)) ?? ""
    }
}
