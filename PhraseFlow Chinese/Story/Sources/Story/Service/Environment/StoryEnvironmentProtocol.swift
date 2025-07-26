//
//  StoryEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Audio
import Foundation
import Combine
import Settings
import TextGeneration
import Study
import Subscription

@MainActor
public protocol StoryEnvironmentProtocol {
    var storySubject: CurrentValueSubject<UUID?, Never> { get }
    func selectChapter(storyId: UUID)
    func playWord(_ word: WordTimeStampData, rate: Float)
    func getAppSettings() throws -> SettingsState
    func playChapter(from word: WordTimeStampData)
    func pauseChapter()
    func setMusicVolume(_ volume: MusicVolume)
    func loadAllChapters() throws -> [Chapter]
    func loadDefinitions() throws -> [Definition]
    func saveChapter(_ chapter: Chapter) throws
    func deleteChapter(_ chapter: Chapter) throws
    func saveAppSettings(_ state: StoryState) throws
    func generateFirstChapter(language: Language, difficulty: Difficulty, voice: Voice, deviceLanguage: Language?, storyPrompt: String?, currentSubscription: SubscriptionLevel?) async throws -> Chapter
    func generateChapter(previousChapters: [Chapter], deviceLanguage: Language?, currentSubscription: SubscriptionLevel?) async throws -> Chapter
    
    // Settings Environment Functions
    func isShowingEnglish() throws -> Bool
    func isShowingDefinition() throws -> Bool
    func getSpeechSpeed() throws -> SpeechSpeed
    func updateSpeechSpeed(_ speed: SpeechSpeed) throws
    
    // Audio Environment Functions
    func isPlayingAudio() -> Bool
    func playSound(_ sound: AppSound)
    
    // Definition Environment Functions
    func getCurrentDefinition() -> Definition?
    func getDefinition(for timestampData: WordTimeStampData) -> Definition?
    func hasDefinition(for timestampData: WordTimeStampData) -> Bool
    func getDefinitions() -> [Definition]
    
    // Translation Environment Functions
    func getCurrentTranslationSentence() -> Sentence?
    func getTranslationChapter() -> Chapter?
}
