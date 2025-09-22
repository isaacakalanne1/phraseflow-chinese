//
//  TranslationEnvironmentTests.swift
//  Translation
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Testing
import Combine
import Foundation
import Settings
@testable import SettingsMocks
import TextGeneration
import TextGenerationMocks
import TextPractice
@testable import TextPracticeMocks
import UserLimit
@testable import UserLimitMocks
import Speech
@testable import SpeechMocks
@testable import SnackBar
@testable import SnackBarMocks
@testable import Translation
@testable import TranslationMocks

class TranslationEnvironmentTests {
    let environment: TranslationEnvironmentProtocol
    let mockTranslationServices: MockTranslationServices
    let mockSpeechEnvironment: MockSpeechEnvironment
    let mockSettingsEnvironment: MockSettingsEnvironment
    let mockTextPracticeEnvironment: MockTextPracticeEnvironment
    let mockTranslationDataStore: MockTranslationDataStore
    let mockUserLimitEnvironment: MockUserLimitEnvironment
    let mockSnackBarEnvironment: MockSnackBarEnvironment
    
    init() {
        self.mockTranslationServices = MockTranslationServices()
        self.mockSpeechEnvironment = MockSpeechEnvironment()
        self.mockSettingsEnvironment = MockSettingsEnvironment()
        self.mockTextPracticeEnvironment = MockTextPracticeEnvironment()
        self.mockTranslationDataStore = MockTranslationDataStore()
        self.mockUserLimitEnvironment = MockUserLimitEnvironment()
        self.mockSnackBarEnvironment = MockSnackBarEnvironment()
        
        self.environment = TranslationEnvironment(
            translationServices: mockTranslationServices,
            speechEnvironment: mockSpeechEnvironment,
            settingsEnvironment: mockSettingsEnvironment,
            textPracticeEnvironment: mockTextPracticeEnvironment,
            translationDataStore: mockTranslationDataStore,
            userLimitEnvironment: mockUserLimitEnvironment,
            snackbarEnvironment: mockSnackBarEnvironment
        )
    }
    
    @Test
    func translateText_success() async throws {
        let text = "Hello, world!"
        let sourceLanguage: Language = .english
        let targetLanguage: Language = .mandarinChinese
        let expectedChapter = Chapter.arrange
        mockTranslationServices.translateTextResult = .success(expectedChapter)
        
        let result = try await environment.translateText(text, from: sourceLanguage, to: targetLanguage)
        
        #expect(result == expectedChapter)
        #expect(mockTranslationServices.translateTextTextSpy == text)
        #expect(mockTranslationServices.translateTextSourceLanguageSpy == sourceLanguage)
        #expect(mockTranslationServices.translateTextTargetLanguageSpy == targetLanguage)
        #expect(mockTranslationServices.translateTextCalled == true)
    }
    
    @Test
    func translateText_error() async throws {
        let text = "Hello, world!"
        let sourceLanguage: Language? = nil
        let targetLanguage: Language = .spanish
        mockTranslationServices.translateTextResult = .failure(.genericError)
        
        do {
            _ = try await environment.translateText(text, from: sourceLanguage, to: targetLanguage)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockTranslationServices.translateTextTextSpy == text)
            #expect(mockTranslationServices.translateTextSourceLanguageSpy == sourceLanguage)
            #expect(mockTranslationServices.translateTextTargetLanguageSpy == targetLanguage)
            #expect(mockTranslationServices.translateTextCalled == true)
        }
    }
    
    @Test
    func saveTranslation_success() throws {
        let chapter = Chapter.arrange
        
        try environment.saveTranslation(chapter)
        
        #expect(mockTranslationDataStore.saveTranslationSpy == chapter)
        #expect(mockTranslationDataStore.saveTranslationCalled == true)
    }
    
    @Test
    func saveTranslation_error() throws {
        let chapter = Chapter.arrange
        mockTranslationDataStore.saveTranslationResult = .failure(.genericError)
        
        do {
            try environment.saveTranslation(chapter)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockTranslationDataStore.saveTranslationSpy == chapter)
            #expect(mockTranslationDataStore.saveTranslationCalled == true)
        }
    }
    
    @Test
    func loadTranslationHistory_success() throws {
        let expectedChapters = [Chapter.arrange, Chapter.arrange]
        mockTranslationDataStore.loadTranslationHistoryResult = .success(expectedChapters)
        
        let result = try environment.loadTranslationHistory()
        
        #expect(result == expectedChapters)
        #expect(mockTranslationDataStore.loadTranslationHistoryCalled == true)
    }
    
    @Test
    func loadTranslationHistory_error() throws {
        mockTranslationDataStore.loadTranslationHistoryResult = .failure(.genericError)
        
        do {
            _ = try environment.loadTranslationHistory()
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockTranslationDataStore.loadTranslationHistoryCalled == true)
        }
    }
    
    @Test
    func deleteTranslation_success() throws {
        let translationId = UUID()
        
        try environment.deleteTranslation(id: translationId)
        
        #expect(mockTranslationDataStore.deleteTranslationIdSpy == translationId)
        #expect(mockTranslationDataStore.deleteTranslationCalled == true)
    }
    
    @Test
    func deleteTranslation_error() throws {
        let translationId = UUID()
        mockTranslationDataStore.deleteTranslationResult = .failure(.genericError)
        
        do {
            try environment.deleteTranslation(id: translationId)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockTranslationDataStore.deleteTranslationIdSpy == translationId)
            #expect(mockTranslationDataStore.deleteTranslationCalled == true)
        }
    }
    
    @Test
    func synthesizeSpeech_success() async throws {
        let chapter = Chapter.arrange
        let voice = Voice.ava
        let language: Language = .english
        let expectedChapter = Chapter.arrange(id: UUID())
        mockSpeechEnvironment.synthesizeSpeechResult = .success(expectedChapter)
        
        let result = try await environment.synthesizeSpeech(for: chapter, voice: voice, language: language)
        
        #expect(result == expectedChapter)
        #expect(mockSpeechEnvironment.synthesizeSpeechChapterSpy == chapter)
        #expect(mockSpeechEnvironment.synthesizeSpeechVoiceSpy == voice)
        #expect(mockSpeechEnvironment.synthesizeSpeechLanguageSpy == language)
        #expect(mockSpeechEnvironment.synthesizeSpeechCalled == true)
    }
    
    @Test
    func synthesizeSpeech_error() async throws {
        let chapter = Chapter.arrange
        let voice = Voice.elvira
        let language: Language = .spanish
        mockSpeechEnvironment.synthesizeSpeechResult = .failure(.genericError)
        
        do {
            _ = try await environment.synthesizeSpeech(for: chapter, voice: voice, language: language)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockSpeechEnvironment.synthesizeSpeechChapterSpy == chapter)
            #expect(mockSpeechEnvironment.synthesizeSpeechVoiceSpy == voice)
            #expect(mockSpeechEnvironment.synthesizeSpeechLanguageSpy == language)
            #expect(mockSpeechEnvironment.synthesizeSpeechCalled == true)
        }
    }
    
    @Test
    func saveAppSettings_success() throws {
        let settings = SettingsState.arrange
        
        try environment.saveAppSettings(settings)
        
        #expect(mockSettingsEnvironment.saveAppSettingsSpy == settings)
        #expect(mockSettingsEnvironment.saveAppSettingsCalled == true)
    }
    
    @Test
    func saveAppSettings_error() throws {
        let settings = SettingsState.arrange
        mockSettingsEnvironment.saveAppSettingsResult = .failure(.genericError)
        
        do {
            try environment.saveAppSettings(settings)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockSettingsEnvironment.saveAppSettingsSpy == settings)
            #expect(mockSettingsEnvironment.saveAppSettingsCalled == true)
        }
    }
    
    @Test
    func canCreateChapter_success() throws {
        let characterCount = 1000
        let characterLimit = 5000
        
        try environment.canCreateChapter(estimatedCharacterCount: characterCount, characterLimitPerDay: characterLimit)
        
        #expect(mockUserLimitEnvironment.canCreateChapterEstimatedCharacterCountSpy == characterCount)
        #expect(mockUserLimitEnvironment.canCreateChapterCharacterLimitPerDaySpy == characterLimit)
        #expect(mockUserLimitEnvironment.canCreateChapterCalled == true)
    }
    
    @Test
    func canCreateChapter_error() throws {
        let characterCount = 10000
        let characterLimit = 5000
        mockUserLimitEnvironment.canCreateChapterResult = .failure(.genericError)
        
        do {
            try environment.canCreateChapter(estimatedCharacterCount: characterCount, characterLimitPerDay: characterLimit)
            Issue.record("Should have thrown an error")
        } catch {
            #expect(mockUserLimitEnvironment.canCreateChapterEstimatedCharacterCountSpy == characterCount)
            #expect(mockUserLimitEnvironment.canCreateChapterCharacterLimitPerDaySpy == characterLimit)
            #expect(mockUserLimitEnvironment.canCreateChapterCalled == true)
        }
    }
    
    @Test
    func canCreateChapter_nilCharacterLimit() throws {
        let characterCount = 1000
        
        try environment.canCreateChapter(estimatedCharacterCount: characterCount, characterLimitPerDay: nil)
        
        #expect(mockUserLimitEnvironment.canCreateChapterEstimatedCharacterCountSpy == characterCount)
        #expect(mockUserLimitEnvironment.canCreateChapterCharacterLimitPerDaySpy == nil)
        #expect(mockUserLimitEnvironment.canCreateChapterCalled == true)
    }
    
    @Test
    func settingsUpdatedSubject_passesThrough() {
        let testSettings = SettingsState.arrange
        mockSettingsEnvironment.settingsUpdatedSubject.send(testSettings)
        
        #expect(environment.settingsUpdatedSubject.value == testSettings)
    }
    
    @Test
    func limitReachedSubject_passesThrough() {
        let testEvent = LimitReachedEvent.freeLimit
        mockUserLimitEnvironment.limitReachedSubject.send(testEvent)
        
        #expect(environment.limitReachedSubject.value == testEvent)
    }
    
    @Test
    func setSnackbarType_delegatesToSnackbarEnvironment() {
        let snackbarType: SnackBarType = .failedToWriteTranslation
        
        environment.setSnackbarType(snackbarType)
        
        #expect(mockSnackBarEnvironment.setSnackbarTypeCalled == true)
        #expect(mockSnackBarEnvironment.setSnackbarTypeSpy == snackbarType)
    }
}
