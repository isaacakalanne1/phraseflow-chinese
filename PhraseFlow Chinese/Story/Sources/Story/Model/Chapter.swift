//
//  Chapter.swift
//  FlowTale
//
//  Created by iakalann on 07/10/2024.
//

import Foundation
import Settings
import Speech
import UIKit

struct Chapter: Codable, Equatable, Hashable {
    var id: UUID
    let storyId: UUID
    var title: String
    var sentences: [Sentence]
    var audioVoice: Voice
    var audio: ChapterAudio
    var passage: String
    
    // Story-level properties moved to Chapter
    var chapterSummary: String
    let difficulty: Difficulty
    let language: Language
    var storyTitle: String
    var currentPlaybackTime: Double = 0
    var currentSentence: Sentence?
    var lastUpdated: Date
    var storyPrompt: String?
    var imageData: Data?
    
    var coverArt: UIImage? {
        if let data = imageData {
            return UIImage(data: data)
        }
        return nil
    }

    var currentSpokenWord: WordTimeStampData? {
        return sentences.flatMap({ $0.timestamps}).last(where: { currentPlaybackTime >= $0.time })
    }

    init(id: UUID = UUID(),
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
         imageData: Data? = nil) {
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

    init(from decoder: any Decoder) throws {
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
