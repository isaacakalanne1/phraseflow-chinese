//
//  StoryEnvironmentProtocol.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Combine
import Audio
import Foundation
import Combine
import Settings
import TextGeneration
import Study
import TextPractice
import UserLimit

public protocol StoryEnvironmentProtocol {
    var textPracticeEnvironment: TextPracticeEnvironmentProtocol { get }
    var goToNextChapterSubject: CurrentValueSubject<Void?, Never> { get }
    var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> { get }
    var limitReachedSubject: CurrentValueSubject<LimitReachedEvent, Never> { get }
    func loadAllChapters() throws -> [Chapter]
    func saveChapter(_ chapter: Chapter) throws
    func deleteChapter(_ chapter: Chapter) throws
    func saveAppSettings(_ settings: SettingsState) throws
    
    func limitReached(_ event: LimitReachedEvent)
    
    func generateTextForChapter(
        previousChapters: [Chapter],
        language: Language?,
        difficulty: Difficulty?,
        voice: Voice?,
        deviceLanguage: Language?,
        storyPrompt: String?
    ) async throws -> Chapter
    
    func generateImageForChapter(
        _ chapter: Chapter,
        previousChapters: [Chapter]
    ) async throws -> Chapter
    
    func generateSpeechForChapter(
        _ chapter: Chapter
    ) async throws -> Chapter
    
    func generateDefinitionsForChapter(
        _ chapter: Chapter,
        deviceLanguage: Language?
    ) async throws -> Chapter

    func playSound(_ sound: AppSound)
    func cleanupDefinitionsNotInChapters(_ chapters: [Chapter]) throws
    func cleanupOrphanedSentenceAudioFiles() throws
}

