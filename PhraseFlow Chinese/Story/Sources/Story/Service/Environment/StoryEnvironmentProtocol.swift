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
import TextPractice

public protocol StoryEnvironmentProtocol {
    var audioEnvironment: AudioEnvironmentProtocol { get }
    var studyEnvironment: StudyEnvironmentProtocol { get }
    var textPracticeEnvironment: TextPracticeEnvironmentProtocol { get }
    func getAppSettings() throws -> SettingsState
    func loadAllChapters() throws -> [Chapter]
    func saveChapter(_ chapter: Chapter) throws
    func deleteChapter(_ chapter: Chapter) throws
    
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
}

