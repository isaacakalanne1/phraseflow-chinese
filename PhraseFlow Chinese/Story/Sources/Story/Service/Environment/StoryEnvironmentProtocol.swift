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

public protocol StoryEnvironmentProtocol {
    var audioEnvironment: AudioEnvironmentProtocol { get }
    var studyEnvironment: StudyEnvironmentProtocol { get }
    func prepareToPlayChapter(_ chapter: Chapter) async
    func playWord(_ word: WordTimeStampData, rate: Float) async
    func getAppSettings() throws -> SettingsState
    func playChapter(from word: WordTimeStampData) async
    func pauseChapter()
    func setMusicVolume(_ volume: MusicVolume)
    func loadAllChapters() throws -> [Chapter]
    func loadDefinitions() throws -> [Definition]
    func saveChapter(_ chapter: Chapter) throws
    func deleteChapter(_ chapter: Chapter) throws
    func saveAppSettings(_ state: StoryState) throws
    func generateChapter(
        previousChapters: [Chapter],
        language: Language?,
        difficulty: Difficulty?,
        voice: Voice?,
        deviceLanguage: Language?,
        storyPrompt: String?,
        currentSubscription: SubscriptionLevel?
    ) async throws -> Chapter
    
    func saveDefinitions(_ definitions: [Definition]) throws
    
    // Settings Environment Functions
    func isShowingEnglish() throws -> Bool
    func isShowingDefinition() throws -> Bool
    func getSpeechSpeed() throws -> SpeechSpeed
    func updateSpeechSpeed(_ speed: SpeechSpeed) throws
    
    // Audio Environment Functions
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

