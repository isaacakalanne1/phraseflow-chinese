//
//  MockTranslationEnvironment.swift
//  Translation
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Combine
import Foundation
import Settings
import SnackBar
import TextGeneration
import TextGenerationMocks
import TextPractice
import TextPracticeMocks
import Translation
import UserLimit

enum MockTranslationEnvironmentError: Error {
    case genericError
}

public class MockTranslationEnvironment: TranslationEnvironmentProtocol {
    
    public var textPracticeEnvironment: TextPracticeEnvironmentProtocol
    public var settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never>
    public var limitReachedSubject: CurrentValueSubject<LimitReachedEvent, Never>
    
    public init(
        textPracticeEnvironment: TextPracticeEnvironmentProtocol = MockTextPracticeEnvironment(),
        settingsUpdatedSubject: CurrentValueSubject<SettingsState?, Never> = .init(nil),
        limitReachedSubject: CurrentValueSubject<LimitReachedEvent, Never> = .init(.freeLimit)
    ) {
        self.textPracticeEnvironment = textPracticeEnvironment
        self.settingsUpdatedSubject = settingsUpdatedSubject
        self.limitReachedSubject = limitReachedSubject
    }
    
    var translateTextTextSpy: String?
    var translateTextSourceLanguageSpy: Language?
    var translateTextTargetLanguageSpy: Language?
    var translateTextCalled = false
    var translateTextResult: Result<Chapter, MockTranslationEnvironmentError> = .success(.arrange)
    public func translateText(_ text: String, from sourceLanguage: Language?, to targetLanguage: Language) async throws -> Chapter {
        translateTextTextSpy = text
        translateTextSourceLanguageSpy = sourceLanguage
        translateTextTargetLanguageSpy = targetLanguage
        translateTextCalled = true
        switch translateTextResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var saveTranslationSpy: Chapter?
    var saveTranslationCalled = false
    var saveTranslationResult: Result<Void, MockTranslationEnvironmentError> = .success(())
    public func saveTranslation(_ chapter: Chapter) throws {
        saveTranslationSpy = chapter
        saveTranslationCalled = true
        switch saveTranslationResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var loadTranslationHistoryCalled = false
    var loadTranslationHistoryResult: Result<[Chapter], MockTranslationEnvironmentError> = .success([.arrange])
    public func loadTranslationHistory() throws -> [Chapter] {
        loadTranslationHistoryCalled = true
        switch loadTranslationHistoryResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var deleteTranslationIdSpy: UUID?
    var deleteTranslationCalled = false
    var deleteTranslationResult: Result<Void, MockTranslationEnvironmentError> = .success(())
    public func deleteTranslation(id: UUID) throws {
        deleteTranslationIdSpy = id
        deleteTranslationCalled = true
        switch deleteTranslationResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var synthesizeSpeechChapterSpy: Chapter?
    var synthesizeSpeechVoiceSpy: Voice?
    var synthesizeSpeechLanguageSpy: Language?
    var synthesizeSpeechCalled = false
    var synthesizeSpeechResult: Result<Chapter, MockTranslationEnvironmentError> = .success(.arrange)
    public func synthesizeSpeech(for chapter: Chapter, voice: Voice, language: Language) async throws -> Chapter {
        synthesizeSpeechChapterSpy = chapter
        synthesizeSpeechVoiceSpy = voice
        synthesizeSpeechLanguageSpy = language
        synthesizeSpeechCalled = true
        switch synthesizeSpeechResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var saveAppSettingsSpy: SettingsState?
    var saveAppSettingsCalled = false
    var saveAppSettingsResult: Result<Void, MockTranslationEnvironmentError> = .success(())
    public func saveAppSettings(_ settings: SettingsState) throws {
        saveAppSettingsSpy = settings
        saveAppSettingsCalled = true
        switch saveAppSettingsResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var canCreateChapterEstimatedCharacterCountSpy: Int?
    var canCreateChapterCharacterLimitPerDaySpy: Int?
    var canCreateChapterCalled = false
    var canCreateChapterResult: Result<Void, MockTranslationEnvironmentError> = .success(())
    public func canCreateChapter(estimatedCharacterCount: Int, characterLimitPerDay: Int?) throws {
        canCreateChapterEstimatedCharacterCountSpy = estimatedCharacterCount
        canCreateChapterCharacterLimitPerDaySpy = characterLimitPerDay
        canCreateChapterCalled = true
        switch canCreateChapterResult {
        case .success(let success):
            return success
        case .failure(let error):
            throw error
        }
    }
    
    var setSnackbarTypeSpy: SnackBarType?
    var setSnackbarTypeCalled = false
    public func setSnackbarType(_ type: SnackBarType) {
        setSnackbarTypeSpy = type
        setSnackbarTypeCalled = true
    }
}
