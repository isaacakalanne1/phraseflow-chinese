//
//  TranslationStateTests.swift
//  Translation
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Testing
import Foundation
import AVKit
import Settings
import SettingsMocks
import TextGeneration
import TextGenerationMocks
@testable import Translation
@testable import TranslationMocks

class TranslationStateTests {
    
    @Test
    func initializer_setsDefaultValues() {
        let translationState = TranslationState()
        
        #expect(translationState.inputText == "")
        #expect(translationState.isTranslating == false)
        #expect(translationState.chapter == nil)
        #expect(translationState.audioPlayer != nil)
        #expect(translationState.isPlayingAudio == false)
        #expect(translationState.currentPlaybackTime == 0)
        #expect(translationState.currentSpokenWord == nil)
        #expect(translationState.settings == SettingsState())
        #expect(translationState.currentSentence == nil)
        #expect(translationState.savedTranslations.isEmpty)
        #expect(translationState.showTextPractice == false)
    }
    
    @Test
    func initializer_withCustomValues() {
        let inputText = "Hello, world!"
        let chapter = Chapter.arrange
        let audioPlayer = AVPlayer()
        let currentSpokenWord = WordTimeStampData.arrange
        let settings = SettingsState.arrange(language: .mandarinChinese)
        let currentSentence = Sentence.arrange
        let savedTranslations = [Chapter.arrange, Chapter.arrange]
        
        let translationState = TranslationState(
            inputText: inputText,
            isTranslating: true,
            chapter: chapter,
            audioPlayer: audioPlayer,
            isPlayingAudio: true,
            currentPlaybackTime: 5.5,
            currentSpokenWord: currentSpokenWord,
            settings: settings,
            currentSentence: currentSentence,
            savedTranslations: savedTranslations,
            showTextPractice: true
        )
        
        #expect(translationState.inputText == inputText)
        #expect(translationState.isTranslating == true)
        #expect(translationState.chapter == chapter)
        #expect(translationState.audioPlayer === audioPlayer)
        #expect(translationState.isPlayingAudio == true)
        #expect(translationState.currentPlaybackTime == 5.5)
        #expect(translationState.currentSpokenWord == currentSpokenWord)
        #expect(translationState.settings == settings)
        #expect(translationState.currentSentence == currentSentence)
        #expect(translationState.savedTranslations == savedTranslations)
        #expect(translationState.showTextPractice == true)
    }
    
    @Test
    func sentence_containing_noChapter_returnsNil() {
        let translationState = TranslationState.arrange(chapter: nil)
        let timestampData = WordTimeStampData.arrange
        
        let result = translationState.sentence(containing: timestampData)
        
        #expect(result == nil)
    }
    
    @Test
    func sentence_containing_timestampNotFound_returnsNil() {
        let timestampData1 = WordTimeStampData.arrange(id: UUID())
        let timestampData2 = WordTimeStampData.arrange(id: UUID())
        let sentence = Sentence.arrange(timestamps: [timestampData1])
        let chapter = Chapter.arrange(sentences: [sentence])
        let translationState = TranslationState.arrange(chapter: chapter)
        
        let result = translationState.sentence(containing: timestampData2)
        
        #expect(result == nil)
    }
    
    @Test
    func sentence_containing_timestampFound_returnsSentence() {
        let timestampData1 = WordTimeStampData.arrange(id: UUID())
        let timestampData2 = WordTimeStampData.arrange(id: UUID())
        let sentence1 = Sentence.arrange(timestamps: [timestampData1])
        let sentence2 = Sentence.arrange(timestamps: [timestampData2])
        let chapter = Chapter.arrange(sentences: [sentence1, sentence2])
        let translationState = TranslationState.arrange(chapter: chapter)
        
        let result = translationState.sentence(containing: timestampData2)
        
        #expect(result == sentence2)
    }
    
    @Test
    func sentence_containing_multipleTimestampsInSentence_returnsSentence() {
        let timestampData1 = WordTimeStampData.arrange(id: UUID())
        let timestampData2 = WordTimeStampData.arrange(id: UUID())
        let timestampData3 = WordTimeStampData.arrange(id: UUID())
        let sentence = Sentence.arrange(timestamps: [timestampData1, timestampData2, timestampData3])
        let chapter = Chapter.arrange(sentences: [sentence])
        let translationState = TranslationState.arrange(chapter: chapter)
        
        let result = translationState.sentence(containing: timestampData2)
        
        #expect(result == sentence)
    }
    
    @Test
    func sentence_containing_emptySentences_returnsNil() {
        let chapter = Chapter.arrange(sentences: [])
        let translationState = TranslationState.arrange(chapter: chapter)
        let timestampData = WordTimeStampData.arrange
        
        let result = translationState.sentence(containing: timestampData)
        
        #expect(result == nil)
    }
    
    @Test
    func equatable_sameStates() {
        let inputText = "Test input"
        let chapter = Chapter.arrange
        let audioPlayer = AVPlayer()
        let currentSpokenWord = WordTimeStampData.arrange
        let settings = SettingsState.arrange(language: .english)
        let currentSentence = Sentence.arrange
        let savedTranslations = [Chapter.arrange]
        
        let state1 = TranslationState.arrange(
            inputText: inputText,
            isTranslating: true,
            chapter: chapter,
            audioPlayer: audioPlayer,
            isPlayingAudio: true,
            currentPlaybackTime: 3.0,
            currentSpokenWord: currentSpokenWord,
            settings: settings,
            currentSentence: currentSentence,
            savedTranslations: savedTranslations,
            showTextPractice: true
        )
        
        let state2 = TranslationState.arrange(
            inputText: inputText,
            isTranslating: true,
            chapter: chapter,
            audioPlayer: audioPlayer,
            isPlayingAudio: true,
            currentPlaybackTime: 3.0,
            currentSpokenWord: currentSpokenWord,
            settings: settings,
            currentSentence: currentSentence,
            savedTranslations: savedTranslations,
            showTextPractice: true
        )
        
        #expect(state1 == state2)
    }
    
    @Test
    func equatable_differentInputText() {
        let state1 = TranslationState.arrange(inputText: "Hello")
        let state2 = TranslationState.arrange(inputText: "Goodbye")
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentIsTranslating() {
        let state1 = TranslationState.arrange(isTranslating: true)
        let state2 = TranslationState.arrange(isTranslating: false)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentChapter() {
        let chapter1 = Chapter.arrange
        let chapter2 = Chapter.arrange
        
        let state1 = TranslationState.arrange(chapter: chapter1)
        let state2 = TranslationState.arrange(chapter: chapter2)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentAudioPlayer() {
        let audioPlayer1 = AVPlayer()
        let audioPlayer2 = AVPlayer()
        
        let state1 = TranslationState.arrange(audioPlayer: audioPlayer1)
        let state2 = TranslationState.arrange(audioPlayer: audioPlayer2)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentIsPlayingAudio() {
        let state1 = TranslationState.arrange(isPlayingAudio: true)
        let state2 = TranslationState.arrange(isPlayingAudio: false)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentCurrentPlaybackTime() {
        let state1 = TranslationState.arrange(currentPlaybackTime: 1.0)
        let state2 = TranslationState.arrange(currentPlaybackTime: 2.0)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentCurrentSpokenWord() {
        let spokenWord1 = WordTimeStampData.arrange(word: "hello")
        let spokenWord2 = WordTimeStampData.arrange(word: "world")
        
        let state1 = TranslationState.arrange(currentSpokenWord: spokenWord1)
        let state2 = TranslationState.arrange(currentSpokenWord: spokenWord2)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentSettings() {
        let settings1 = SettingsState.arrange(language: .english)
        let settings2 = SettingsState.arrange(language: .spanish)
        
        let state1 = TranslationState.arrange(settings: settings1)
        let state2 = TranslationState.arrange(settings: settings2)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentCurrentSentence() {
        let sentence1 = Sentence.arrange(original: "First sentence")
        let sentence2 = Sentence.arrange(original: "Second sentence")
        
        let state1 = TranslationState.arrange(currentSentence: sentence1)
        let state2 = TranslationState.arrange(currentSentence: sentence2)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentSavedTranslations() {
        let translations1 = [Chapter.arrange]
        let translations2 = [Chapter.arrange, Chapter.arrange]
        
        let state1 = TranslationState.arrange(savedTranslations: translations1)
        let state2 = TranslationState.arrange(savedTranslations: translations2)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_differentShowTextPractice() {
        let state1 = TranslationState.arrange(showTextPractice: true)
        let state2 = TranslationState.arrange(showTextPractice: false)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_nilVsNonNilChapter() {
        let state1 = TranslationState.arrange(chapter: nil)
        let state2 = TranslationState.arrange(chapter: Chapter.arrange)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_nilVsNonNilCurrentSpokenWord() {
        let state1 = TranslationState.arrange(currentSpokenWord: nil)
        let state2 = TranslationState.arrange(currentSpokenWord: WordTimeStampData.arrange)
        
        #expect(state1 != state2)
    }
    
    @Test
    func equatable_nilVsNonNilCurrentSentence() {
        let state1 = TranslationState.arrange(currentSentence: nil)
        let state2 = TranslationState.arrange(currentSentence: Sentence.arrange)
        
        #expect(state1 != state2)
    }
}

