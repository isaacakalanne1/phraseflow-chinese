//
//  TranslationEnvironment.swift
//  Translation
//
//  Created by iakalann on 18/07/2025.
//

import Audio
import Foundation
import Speech
import Study
import Settings
import TextGeneration
import TextPractice

public struct TranslationEnvironment: TranslationEnvironmentProtocol {
    public let translationServices: TranslationServicesProtocol
    public let speechEnvironment: SpeechEnvironmentProtocol
    public let studyEnvironment: StudyEnvironmentProtocol
    public let settingsEnvironment: SettingsEnvironmentProtocol
    public let textPracticeEnvironment: TextPracticeEnvironmentProtocol
    public let translationDataStore: TranslationDataStoreProtocol
    
    public init(
        speechRepository: SpeechRepositoryProtocol,
        definitionServices: DefinitionServicesProtocol,
        definitionDataStore: DefinitionDataStoreProtocol,
        audioEnvironment: AudioEnvironmentProtocol,
        settingsEnvironment: SettingsEnvironmentProtocol,
        textPracticeEnvironment: TextPracticeEnvironmentProtocol,
        settingsDataStore: SettingsDataStoreProtocol
    ) {
        self.translationServices = TranslationServices()
        self.speechEnvironment = SpeechEnvironment(speechRepository: speechRepository)
        self.studyEnvironment = StudyEnvironment(
            definitionServices: definitionServices,
            dataStore: definitionDataStore,
            audioEnvironment: audioEnvironment,
            settingsEnvironment: settingsEnvironment)
        self.settingsEnvironment = settingsEnvironment
        self.textPracticeEnvironment = textPracticeEnvironment
        self.translationDataStore = TranslationDataStore()
    }
    
    public func translateText(_ text: String, from sourceLanguage: Language?, to targetLanguage: Language) async throws -> Chapter {
        return try await translationServices.translateText(text, from: sourceLanguage, to: targetLanguage)
    }
    
    public func breakdownText(_ text: String, textLanguage: Language, deviceLanguage: Language) async throws -> Chapter {
        return try await translationServices.breakdownText(text, textLanguage: textLanguage, deviceLanguage: deviceLanguage)
    }
    
    public func synthesizeSpeech(for chapter: Chapter, voice: Voice, language: Language) async throws -> Chapter {
        return try await speechEnvironment.synthesizeSpeech(for: chapter, voice: voice, language: language)
    }
    
    public func saveDefinitions(_ definitions: [Definition]) throws {
        try studyEnvironment.saveDefinitions(definitions)
        textPracticeEnvironment.addDefinitions(definitions)
    }
    
    public func saveSentenceAudio(_ audioData: Data, id: UUID) throws {
        try studyEnvironment.saveSentenceAudio(audioData, id: id)
    }
    
    public func getAppSettings() throws -> SettingsState {
        return try settingsEnvironment.loadAppSettings()
    }
    
    public func saveAppSettings(_ settings: SettingsState) throws {
        try settingsEnvironment.saveAppSettings(settings)
    }
}
