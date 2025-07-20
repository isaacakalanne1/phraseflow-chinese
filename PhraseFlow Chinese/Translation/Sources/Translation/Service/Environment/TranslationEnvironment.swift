//
//  TranslationEnvironment.swift
//  Translation
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Speech
import Definition
import Settings

struct TranslationEnvironment: TranslationEnvironmentProtocol {
    let translationServices: TranslationServicesProtocol
    let speechEnvironment: SpeechEnvironmentProtocol
    let definitionEnvironment: DefinitionEnvironmentProtocol
    let settingsEnvironment: SettingsEnvironmentProtocol
    let translationDataStore: TranslationDataStoreProtocol
    
    init(translationServices: TranslationServicesProtocol, speechEnvironment: SpeechEnvironmentProtocol, definitionEnvironment: DefinitionEnvironmentProtocol, settingsEnvironment: SettingsEnvironmentProtocol, translationDataStore: TranslationDataStoreProtocol) {
        self.translationServices = translationServices
        self.speechEnvironment = speechEnvironment
        self.definitionEnvironment = definitionEnvironment
        self.settingsEnvironment = settingsEnvironment
        self.translationDataStore = translationDataStore
    }
    
    init() {
        self.translationServices = TranslationServices()
        self.speechEnvironment = SpeechEnvironment()
        self.definitionEnvironment = DefinitionEnvironment()
        self.settingsEnvironment = SettingsEnvironment()
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
        return try await definitionEnvironment.fetchDefinitions(in: sentence, chapter: chapter, deviceLanguage: deviceLanguage)
    }
    
    func saveDefinitions(_ definitions: [Definition]) throws {
        try definitionEnvironment.saveDefinitions(definitions)
    }
    
    func saveSentenceAudio(_ audioData: Data, id: UUID) throws {
        try definitionEnvironment.saveSentenceAudio(audioData, id: id)
    }
}