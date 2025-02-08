//
//  Story.swift
//  FlowTale
//
//  Created by iakalann on 07/10/2024.
//

import SwiftUI

struct ChapterAudio: Codable, Equatable, Hashable {
    let timestamps: [WordTimeStampData]
    let data: Data
}

struct Story: Codable, Equatable, Hashable {
    var id: UUID
    var briefLatestStorySummary: String
    var totalSummary = ""
    var prequelIds: [UUID] = []
    var prequelSummaries: [String] = []
    let difficulty: Difficulty
    let language: Language

    var title: String
    var chapters: [Chapter]       // You can choose not to decode or encode in your store
    var currentChapterIndex = 0
    var currentSentenceIndex = 0
    var currentPlaybackTime: Double = 0
    var lastUpdated: Date
    var storyPrompt: String
    var imageData: Data?
    var sequelId: UUID?

    var coverArt: UIImage? {
        if let data = imageData {
            return UIImage(data: data)
        }
        return nil
    }

    init(briefLatestStorySummary: String = "",
         totalSummary: String = "",
         sequelId: UUID? = nil,
         difficulty: Difficulty,
         language: Language,
         title: String = "",
         chapters: [Chapter] = [],
         storyPrompt: String,
         imageData: Data? = nil,
         currentChapterIndex: Int = 0,
         currentSentenceIndex: Int = 0,
         currentPlaybackTime: Double = 0,
         lastUpdated: Date = .now) {
        self.id = UUID()
        self.briefLatestStorySummary = briefLatestStorySummary
        self.totalSummary = totalSummary
        self.sequelId = sequelId
        self.difficulty = difficulty
        self.language = language
        self.title = title
        self.chapters = chapters
        self.currentChapterIndex = currentChapterIndex
        self.currentSentenceIndex = currentSentenceIndex
        self.currentPlaybackTime = currentPlaybackTime
        self.lastUpdated = lastUpdated
        self.storyPrompt = storyPrompt
        self.imageData = imageData
    }

    // Custom decoder to assign default values
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id                       = try container.decode(UUID.self, forKey: .id)
        self.briefLatestStorySummary  = try container.decode(String.self, forKey: .briefLatestStorySummary)
        self.totalSummary             = (try? container.decode(String.self, forKey: .totalSummary)) ?? ""
        self.sequelId                 = try? container.decode(UUID?.self, forKey: .sequelId)
        self.prequelIds               = (try? container.decode([UUID].self, forKey: .prequelIds)) ?? []
        self.difficulty               = try container.decode(Difficulty.self, forKey: .difficulty)
        self.language                 = try container.decode(Language.self, forKey: .language)
        self.title                    = try container.decode(String.self, forKey: .title)
        self.chapters                 = (try? container.decode([Chapter].self, forKey: .chapters)) ?? []
        self.currentChapterIndex      = (try? container.decode(Int.self, forKey: .currentChapterIndex)) ?? 0
        self.currentSentenceIndex     = (try? container.decode(Int.self, forKey: .currentSentenceIndex)) ?? 0
        self.currentPlaybackTime      = (try? container.decode(Double.self, forKey: .currentPlaybackTime)) ?? 0
        self.lastUpdated              = (try? container.decode(Date.self, forKey: .lastUpdated)) ?? .now
        self.storyPrompt              = (try? container.decode(String.self, forKey: .storyPrompt)) ?? ""
        self.imageData                = try? container.decode(Data.self, forKey: .imageData)
    }
}
