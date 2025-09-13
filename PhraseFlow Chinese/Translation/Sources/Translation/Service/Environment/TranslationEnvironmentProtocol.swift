//
//  TranslationEnvironmentProtocol.swift
//  Translation
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Settings
import TextGeneration
import TextPractice
import UserLimit
import Combine

public protocol TranslationEnvironmentProtocol {
    var textPracticeEnvironment: TextPracticeEnvironmentProtocol { get }
    var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> { get }
    var limitReachedSubject: CurrentValueSubject<LimitReachedEvent, Never> { get }
    
    func translateText(_ text: String, from sourceLanguage: Language?, to targetLanguage: Language) async throws -> Chapter
    func saveTranslation(_ chapter: Chapter) throws
    func loadTranslationHistory() throws -> [Chapter]
    func deleteTranslation(id: UUID) throws

    func synthesizeSpeech(for chapter: Chapter, voice: Voice, language: Language) async throws -> Chapter
    func saveAppSettings(_ settings: SettingsState) throws
    func canCreateChapter(estimatedCharacterCount: Int, characterLimitPerDay: Int?) throws
}
