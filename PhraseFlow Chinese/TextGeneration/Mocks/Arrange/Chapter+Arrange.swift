//
//  Chapter+Arrange.swift
//  TextGeneration
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import Settings
import TextGeneration

public extension Chapter {
    static var arrange: Chapter {
        .arrange()
    }
    
    static func arrange(
        id: UUID = UUID(),
        storyId: UUID = UUID(),
        title: String = "",
        sentences: [Sentence] = [.arrange],
        audioVoice: Voice = .elvira,
        audio: ChapterAudio = .arrange,
        passage: String = "passage",
        chapterSummary: String = "chapterSummary",
        difficulty: Difficulty = .beginner,
        deviceLanguage: Language = .english,
        language: Language = .spanish,
        storyTitle: String = "storyTitle",
        currentPlaybackTime: Double = 0,
        currentSentence: Sentence? = nil,
        lastUpdated: Date = .now,
        storyPrompt: String? = nil,
        imageData: Data? = nil
    ) -> Chapter {
        .init(
            id: id,
            storyId: storyId,
            title: title,
            sentences: sentences,
            audioVoice: audioVoice,
            audio: audio,
            passage: passage,
            chapterSummary: chapterSummary,
            difficulty: difficulty,
            deviceLanguage: deviceLanguage,
            language: language,
            storyTitle: storyTitle,
            currentPlaybackTime: currentPlaybackTime,
            currentSentence: currentSentence,
            lastUpdated: lastUpdated,
            storyPrompt: storyPrompt,
            imageData: imageData
        )
    }
}
