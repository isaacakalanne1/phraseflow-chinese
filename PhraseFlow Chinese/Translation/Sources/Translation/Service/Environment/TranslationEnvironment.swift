//
//  TranslationEnvironment.swift
//  Translation
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Speech
import Settings
import TextGeneration
import TextPractice
import UserLimit
import Combine
import SnackBar

public struct TranslationEnvironment: TranslationEnvironmentProtocol {
    private let translationServices: TranslationServicesProtocol
    private let speechEnvironment: SpeechEnvironmentProtocol
    private let settingsEnvironment: SettingsEnvironmentProtocol
    public let textPracticeEnvironment: TextPracticeEnvironmentProtocol
    private let translationDataStore: TranslationDataStoreProtocol
    private let userLimitEnvironment: UserLimitEnvironmentProtocol
    private let snackbarEnvironment: SnackBarEnvironmentProtocol
    public var limitReachedSubject: CurrentValueSubject<LimitReachedEvent, Never> {
        userLimitEnvironment.limitReachedSubject
    }
    public var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> {
        settingsEnvironment.settingsUpdatedSubject
    }
    
    public init(
        translationServices: TranslationServicesProtocol,
        speechEnvironment: SpeechEnvironmentProtocol,
        settingsEnvironment: SettingsEnvironmentProtocol,
        textPracticeEnvironment: TextPracticeEnvironmentProtocol,
        translationDataStore: TranslationDataStoreProtocol,
        userLimitEnvironment: UserLimitEnvironmentProtocol,
        snackbarEnvironment: SnackBarEnvironmentProtocol
    ) {
        self.translationServices = translationServices
        self.speechEnvironment = speechEnvironment
        self.settingsEnvironment = settingsEnvironment
        self.textPracticeEnvironment = textPracticeEnvironment
        self.userLimitEnvironment = userLimitEnvironment
        self.snackbarEnvironment = snackbarEnvironment
        self.translationDataStore = translationDataStore
    }
    
    public func translateText(_ text: String, from sourceLanguage: Language?, to targetLanguage: Language) async throws -> Chapter {
        return try await translationServices.translateText(text, from: sourceLanguage, to: targetLanguage)
    }
    
    public func saveTranslation(_ chapter: Chapter) throws {
        try translationDataStore.saveTranslation(chapter)
    }
    
    public func loadTranslationHistory() throws -> [Chapter] {
        try translationDataStore.loadTranslationHistory()
    }
    
    public func deleteTranslation(id: UUID) throws {
        try translationDataStore.deleteTranslation(id: id)
    }
    
    public func synthesizeSpeech(for chapter: Chapter, voice: Voice, language: Language) async throws -> Chapter {
        return try await speechEnvironment.synthesizeSpeech(for: chapter, voice: voice, language: language)
    }
    
    public func saveAppSettings(_ settings: SettingsState) throws {
        try settingsEnvironment.saveAppSettings(settings)
    }
    
    public func canCreateChapter(estimatedCharacterCount: Int, characterLimitPerDay: Int?) throws {
        try userLimitEnvironment.canCreateChapter(estimatedCharacterCount: estimatedCharacterCount,
                                                  characterLimitPerDay: characterLimitPerDay)
    }
    
    public func setSnackbarType(_ type: SnackBarType) {
        snackbarEnvironment.setSnackbarType(type)
    }
}
