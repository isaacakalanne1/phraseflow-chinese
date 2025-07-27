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

public struct TranslationEnvironment: TranslationEnvironmentProtocol {
    public let translationServices: TranslationServicesProtocol
    public let speechEnvironment: SpeechEnvironmentProtocol
    public let studyEnvironment: StudyEnvironmentProtocol
    public let settingsEnvironment: SettingsEnvironmentProtocol
    public let translationDataStore: TranslationDataStoreProtocol
    
    public init(
        speechRepository: SpeechRepositoryProtocol,
        definitionServices: DefinitionServicesProtocol,
        definitionDataStore: DefinitionDataStoreProtocol,
        audioEnvironment: AudioEnvironmentProtocol,
        settingsEnvironment: SettingsEnvironmentProtocol,
        settingsDataStore: SettingsDataStoreProtocol
    ) {
        self.translationServices = TranslationServices()
        self.speechEnvironment = SpeechEnvironment(speechRepository: speechRepository)
        self.studyEnvironment = StudyEnvironment(
            definitionServices: definitionServices,
            dataStore: definitionDataStore,
            audioEnvironment: audioEnvironment,
            settingsEnvironment: settingsEnvironment)
        self.settingsEnvironment = SettingsEnvironment(
            settingsDataStore: settingsDataStore,
            audioEnvironment: audioEnvironment
        )
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
    
    public func fetchDefinitions(in sentence: Sentence?, chapter: Chapter, deviceLanguage: Language) async throws -> [Definition] {
        return try await studyEnvironment.fetchDefinitions(in: sentence, chapter: chapter, deviceLanguage: deviceLanguage)
    }
    
    public func saveDefinitions(_ definitions: [Definition]) throws {
        try studyEnvironment.saveDefinitions(definitions)
    }
    
    public func saveSentenceAudio(_ audioData: Data, id: UUID) throws {
        try studyEnvironment.saveSentenceAudio(audioData, id: id)
    }
}
