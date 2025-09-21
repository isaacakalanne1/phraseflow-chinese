//
//  ChapterTests.swift
//  TextGeneration
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import Testing
import UIKit
@testable import Settings
@testable import TextGeneration
@testable import TextGenerationMocks

class ChapterTests {
    @Test
    func initParameters() {
        let id = UUID()
        let storyId = UUID()
        let title = "Test Chapter"
        let sentences = [Sentence.arrange]
        let audioVoice = Voice.denise
        let audio = ChapterAudio.arrange
        let passage = "Test passage"
        let chapterSummary = "Test summary"
        let difficulty = Difficulty.advanced
        let deviceLanguage = Language.english
        let language = Language.mandarinChinese
        let storyTitle = "Test Story"
        let currentPlaybackTime = 123.45
        let currentSentence = Sentence.arrange
        let lastUpdated = Date()
        let storyPrompt = "Test prompt"
        let testImageData = Data("test image data".utf8)
        
        let chapter = Chapter(
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
            imageData: testImageData
        )
        
        #expect(chapter.id == id)
        #expect(chapter.storyId == storyId)
        #expect(chapter.title == title)
        #expect(chapter.sentences == sentences)
        #expect(chapter.audioVoice == audioVoice)
        #expect(chapter.audio == audio)
        #expect(chapter.passage == passage)
        #expect(chapter.chapterSummary == chapterSummary)
        #expect(chapter.difficulty == difficulty)
        #expect(chapter.deviceLanguage == deviceLanguage)
        #expect(chapter.language == language)
        #expect(chapter.storyTitle == storyTitle)
        #expect(chapter.currentPlaybackTime == currentPlaybackTime)
        #expect(chapter.currentSentence == currentSentence)
        #expect(chapter.lastUpdated == lastUpdated)
        #expect(chapter.storyPrompt == storyPrompt)
        #expect(chapter.imageData == testImageData)
        
        // Test computed properties work correctly
        #expect(chapter.coverArt == UIImage(data: testImageData))
    }
    
    @Test
    func init_withPlaybackTimeAndTimestamps() {
        let timestamp1 = WordTimeStampData.arrange(time: 1.0)
        let timestamp2 = WordTimeStampData.arrange(time: 3.0)
        let timestamp3 = WordTimeStampData.arrange(time: 5.0)
        let timestamp4 = WordTimeStampData.arrange(time: 7.0)
        
        let sentence1 = Sentence.arrange(timestamps: [timestamp1, timestamp2])
        let sentence2 = Sentence.arrange(timestamps: [timestamp3, timestamp4])
        
        let chapter = Chapter(
            storyId: UUID(),
            title: "Test Chapter",
            sentences: [sentence1, sentence2],
            audioVoice: .elvira,
            audio: .arrange,
            passage: "Test passage",
            deviceLanguage: .english,
            language: .spanish,
            currentPlaybackTime: 6.0
        )
        
        #expect(chapter.currentSpokenWord == timestamp3)
        #expect(chapter.currentPlaybackTime == 6.0)
    }
    
    @Test
    func init_withPlaybackTimeBeforeFirstTimestamp() {
        let timestamp1 = WordTimeStampData.arrange(time: 2.0)
        let timestamp2 = WordTimeStampData.arrange(time: 4.0)
        
        let sentence = Sentence.arrange(timestamps: [timestamp1, timestamp2])
        let chapter = Chapter(
            storyId: UUID(),
            title: "Test Chapter",
            sentences: [sentence],
            audioVoice: .elvira,
            audio: .arrange,
            passage: "Test passage",
            deviceLanguage: .english,
            language: .spanish,
            currentPlaybackTime: 1.0
        )
        
        #expect(chapter.currentSpokenWord == timestamp1)
    }
    
    @Test
    func init_withPlaybackTimeAfterLastTimestamp() {
        let timestamp1 = WordTimeStampData.arrange(time: 1.0)
        let timestamp2 = WordTimeStampData.arrange(time: 3.0)
        
        let sentence = Sentence.arrange(timestamps: [timestamp1, timestamp2])
        let chapter = Chapter(
            storyId: UUID(),
            title: "Test Chapter",
            sentences: [sentence],
            audioVoice: .elvira,
            audio: .arrange,
            passage: "Test passage",
            deviceLanguage: .english,
            language: .spanish,
            currentPlaybackTime: 10.0
        )
        
        #expect(chapter.currentSpokenWord == timestamp2)
    }
    
    @Test
    func init_withNoTimestamps() {
        let sentence = Sentence.arrange(timestamps: [])
        let chapter = Chapter(
            storyId: UUID(),
            title: "Test Chapter",
            sentences: [sentence],
            audioVoice: .elvira,
            audio: .arrange,
            passage: "Test passage",
            deviceLanguage: .english,
            language: .spanish,
            currentPlaybackTime: 5.0
        )
        
        #expect(chapter.currentSpokenWord == nil)
    }
}
