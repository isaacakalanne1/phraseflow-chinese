//
//  Chapter.swift
//  FlowTale
//
//  Created by iakalann on 07/10/2024.
//

import Foundation
import Settings
import UIKit

public struct Chapter: Codable, Equatable, Hashable, Sendable {
    public var id: UUID
    public let storyId: UUID
    public var title: String
    public var sentences: [Sentence]
    public var audioVoice: Voice
    public var audio: ChapterAudio
    public var passage: String
    
    // Story-level properties moved to Chapter
    public var chapterSummary: String
    public let difficulty: Difficulty
    public let language: Language
    public var storyTitle: String
    public var currentPlaybackTime: Double = 0
    public var currentSentence: Sentence?
    public var lastUpdated: Date
    var storyPrompt: String?
    public var imageData: Data?
    
    public var coverArt: UIImage? {
        if let data = imageData {
            return UIImage(data: data)
        }
        return nil
    }

    public var currentSpokenWord: WordTimeStampData? {
        let allTimestamps = sentences.flatMap({ $0.timestamps})
        return allTimestamps.last(where: { currentPlaybackTime >= $0.time }) ?? allTimestamps.first
    }

    public init(
        id: UUID = UUID(),
        storyId: UUID,
        title: String,
        sentences: [Sentence],
        audioVoice: Voice,
        audio: ChapterAudio,
        passage: String,
        chapterSummary: String = "",
        difficulty: Difficulty = .beginner,
        language: Language,
        storyTitle: String = "",
        currentPlaybackTime: Double = 0,
        currentSentence: Sentence? = nil,
        lastUpdated: Date = .now,
        storyPrompt: String? = nil,
        imageData: Data? = nil
    ) {
        self.id = id
        self.storyId = storyId
        self.title = title
        self.sentences = sentences
        self.audioVoice = audioVoice
        self.audio = audio
        self.passage = passage
        self.chapterSummary = chapterSummary
        self.difficulty = difficulty
        self.language = language
        self.storyTitle = storyTitle
        self.currentPlaybackTime = currentPlaybackTime
        self.currentSentence = currentSentence
        self.lastUpdated = lastUpdated
        self.storyPrompt = storyPrompt
        self.imageData = imageData
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? container.decode(UUID.self, forKey: .id)) ?? UUID()
        self.storyId = (try? container.decode(UUID.self, forKey: .storyId)) ?? UUID()
        self.title = try container.decode(String.self, forKey: .title)
        self.sentences = try container.decode([Sentence].self, forKey: .sentences)
        self.audioVoice = try container.decode(Voice.self, forKey: .audioVoice)
        self.audio = (try? container.decode(ChapterAudio.self, forKey: .audio)) ?? ChapterAudio(data: Data())
        let newLine = """


"""
        self.passage = (try? container.decode(String.self, forKey: .passage)) ?? sentences.reduce("") { $0 + newLine + $1.original }
        self.chapterSummary = (try? container.decode(String.self, forKey: .chapterSummary)) ?? ""
        self.difficulty = (try? container.decode(Difficulty.self, forKey: .difficulty)) ?? .beginner
        self.language = (try? container.decode(Language.self, forKey: .language)) ?? .english
        self.storyTitle = (try? container.decode(String.self, forKey: .storyTitle)) ?? ""
        self.currentPlaybackTime = (try? container.decode(Double.self, forKey: .currentPlaybackTime)) ?? 0
        self.currentSentence = try? container.decode(Sentence.self, forKey: .currentSentence)
        self.lastUpdated = (try? container.decode(Date.self, forKey: .lastUpdated)) ?? .now
        self.storyPrompt = try? container.decode(String.self, forKey: .storyPrompt)
        self.imageData = try? container.decode(Data.self, forKey: .imageData)
    }
}
