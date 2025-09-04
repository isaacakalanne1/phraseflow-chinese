//
//  TranslationEnvironmentProtocol.swift
//  Translation
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import Speech
import Study
import Settings
import TextGeneration
import TextPractice

public protocol TranslationEnvironmentProtocol {
    var translationServices: TranslationServicesProtocol { get }
    var speechEnvironment: SpeechEnvironmentProtocol { get }
    var studyEnvironment: StudyEnvironmentProtocol { get }
    var settingsEnvironment: SettingsEnvironmentProtocol { get }
    var textPracticeEnvironment: TextPracticeEnvironmentProtocol { get }
    var translationDataStore: TranslationDataStoreProtocol { get }
    
    func translateText(_ text: String, from sourceLanguage: Language?, to targetLanguage: Language) async throws -> Chapter
    func breakdownText(_ text: String, textLanguage: Language, deviceLanguage: Language) async throws -> Chapter
    func synthesizeSpeech(for chapter: Chapter, voice: Voice, language: Language) async throws -> (chapter: Chapter, initialDefinitions: [Definition])
    func fetchDefinitions(in sentence: Sentence?, chapter: Chapter, deviceLanguage: Language) async throws -> [Definition]
    func saveDefinitions(_ definitions: [Definition]) throws
    func saveSentenceAudio(_ audioData: Data, id: UUID) throws
    func getAppSettings() throws -> SettingsState
}
