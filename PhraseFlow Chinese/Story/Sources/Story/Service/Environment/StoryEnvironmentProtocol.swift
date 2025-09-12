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
    func getAppSettings() throws -> SettingsState
    func loadAllChapters() throws -> [Chapter]
    func saveChapter(_ chapter: Chapter) throws
    func deleteChapter(_ chapter: Chapter) throws
    func generateChapter(
        previousChapters: [Chapter],
        language: Language?,
        difficulty: Difficulty?,
        voice: Voice?,
        deviceLanguage: Language?,
        storyPrompt: String?,
        currentSubscription: SubscriptionLevel?
    ) async throws -> Chapter

    func playSound(_ sound: AppSound)
}

