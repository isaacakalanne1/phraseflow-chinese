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

struct TranslationEnvironment: TranslationEnvironmentProtocol {
    let translationServices: TranslationServicesProtocol
    let speechEnvironment: SpeechEnvironmentProtocol
    let studyEnvironment: StudyEnvironmentProtocol
    let settingsEnvironment: SettingsEnvironmentProtocol
    let translationDataStore: TranslationDataStoreProtocol
    
    init(
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
    
    func translateText(_ text: String, from sourceLanguage: Language?, to targetLanguage: Language) async throws -> Chapter {
        return try await translationServices.translateText(text, from: sourceLanguage, to: targetLanguage)
    }
    
    func breakdownText(_ text: String, textLanguage: Language, deviceLanguage: Language) async throws -> Chapter {
        return try await translationServices.breakdownText(text, textLanguage: textLanguage, deviceLanguage: deviceLanguage)
    }
    
    func synthesizeSpeech(for chapter: Chapter, voice: Voice, language: Language) async throws -> Chapter {
        return try await speechEnvironment.synthesizeSpeech(for: chapter, voice: voice, language: language)
    }
    
    func fetchDefinitions(in sentence: Sentence?, chapter: Chapter, deviceLanguage: Language) async throws -> [Definition] {
        return try await studyEnvironment.fetchDefinitions(in: sentence, chapter: chapter, deviceLanguage: deviceLanguage)
    }
    
    func saveDefinitions(_ definitions: [Definition]) throws {
        try studyEnvironment.saveDefinitions(definitions)
    }
    
    func saveSentenceAudio(_ audioData: Data, id: UUID) throws {
        try studyEnvironment.saveSentenceAudio(audioData, id: id)
    }
}
