//
//  TranslationMiddlewareTests.swift
//  Translation
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Foundation
import Testing
import Audio
import Settings
import SettingsMocks
import TextGeneration
import TextGenerationMocks
import UserLimit
import SnackBar
@testable import Translation
@testable import TranslationMocks

final class TranslationMiddlewareTests {
    
    let mockEnvironment: MockTranslationEnvironment
    
    init() {
        mockEnvironment = MockTranslationEnvironment()
    }
    
    @Test
    func translateText_emptyInput_returnsTranslationInProgressFalse() async {
        let state = TranslationState.arrange(inputText: "")
        
        let resultAction = await translationMiddleware(
            state,
            .translateText,
            mockEnvironment
        )
        
        #expect(resultAction == .translationInProgress(false))
        #expect(mockEnvironment.translateTextCalled == false)
        #expect(mockEnvironment.canCreateChapterCalled == false)
    }
    
    @Test
    func translateText_success_returnsSynthesizeAudio() async {
        let inputText = "Hello world"
        let state = TranslationState.arrange(
            inputText: inputText,
            settings: .arrange(targetLanguage: .spanish, subscriptionLevel: .level1)
        )
        let expectedChapter = Chapter.arrange(title: "Translated Chapter")
        
        mockEnvironment.canCreateChapterResult = .success(())
        mockEnvironment.translateTextResult = .success(expectedChapter)
        
        let resultAction = await translationMiddleware(
            state,
            .translateText,
            mockEnvironment
        )
        
        #expect(resultAction == .synthesizeAudio(expectedChapter, .spanish))
        #expect(mockEnvironment.canCreateChapterCalled == true)
        #expect(mockEnvironment.canCreateChapterEstimatedCharacterCountSpy == inputText.count * 2)
        #expect(mockEnvironment.canCreateChapterCharacterLimitPerDaySpy == 15000)
        #expect(mockEnvironment.translateTextCalled == true)
        #expect(mockEnvironment.translateTextTextSpy == inputText)
        #expect(mockEnvironment.translateTextSourceLanguageSpy == Language.deviceLanguage)
        #expect(mockEnvironment.translateTextTargetLanguageSpy == .spanish)
    }
    
    @Test
    func translateText_freeUserLimitReached_sendsLimitEventAndReturnsFailed() async {
        let state = TranslationState.arrange(inputText: "Test text")
        
        mockEnvironment.canCreateChapterResult = .failure(.genericError)
        
        let resultAction = await translationMiddleware(
            state,
            .translateText,
            mockEnvironment
        )
        
        #expect(resultAction == .failedToTranslate)
        #expect(mockEnvironment.canCreateChapterCalled == true)
        #expect(mockEnvironment.translateTextCalled == false)
    }
    
    @Test
    func translateText_translationFails_returnsFailedToTranslate() async {
        let state = TranslationState.arrange(inputText: "Test text")
        
        mockEnvironment.canCreateChapterResult = .success(())
        mockEnvironment.translateTextResult = .failure(.genericError)
        
        let resultAction = await translationMiddleware(
            state,
            .translateText,
            mockEnvironment
        )
        
        #expect(resultAction == .failedToTranslate)
        #expect(mockEnvironment.canCreateChapterCalled == true)
        #expect(mockEnvironment.translateTextCalled == true)
    }
    
    @Test
    func synthesizeAudio_success_returnsOnSynthesizedTranslationAudio() async {
        let chapter = Chapter.arrange
        let language = Language.spanish
        let state = TranslationState.arrange(settings: .arrange(voice: .elvira))
        let synthesizedChapter = Chapter.arrange(title: "Synthesized")
        
        mockEnvironment.synthesizeSpeechResult = .success(synthesizedChapter)
        
        let resultAction = await translationMiddleware(
            state,
            .synthesizeAudio(chapter, language),
            mockEnvironment
        )
        
        #expect(resultAction == .onSynthesizedTranslationAudio(synthesizedChapter))
        #expect(mockEnvironment.synthesizeSpeechCalled == true)
        #expect(mockEnvironment.synthesizeSpeechChapterSpy == chapter)
        #expect(mockEnvironment.synthesizeSpeechVoiceSpy == .elvira)
        #expect(mockEnvironment.synthesizeSpeechLanguageSpy == language)
    }
    
    @Test
    func synthesizeAudio_voiceLanguageMismatch_usesFirstVoiceForLanguage() async {
        let chapter = Chapter.arrange
        let language = Language.mandarinChinese
        let state = TranslationState.arrange(settings: .arrange(voice: .elvira)) // Spanish voice
        let synthesizedChapter = Chapter.arrange
        
        mockEnvironment.synthesizeSpeechResult = .success(synthesizedChapter)
        
        let resultAction = await translationMiddleware(
            state,
            .synthesizeAudio(chapter, language),
            mockEnvironment
        )
        
        #expect(resultAction == .onSynthesizedTranslationAudio(synthesizedChapter))
        #expect(mockEnvironment.synthesizeSpeechCalled == true)
        #expect(mockEnvironment.synthesizeSpeechVoiceSpy == language.voices.first)
        #expect(mockEnvironment.synthesizeSpeechLanguageSpy == language)
    }
    
    @Test
    func synthesizeAudio_synthesizeFails_returnsFailedToSynthesizeAudio() async {
        let chapter = Chapter.arrange
        let language = Language.spanish
        let state = TranslationState.arrange(settings: .arrange(voice: .elvira))
        
        mockEnvironment.synthesizeSpeechResult = .failure(.genericError)
        
        let resultAction = await translationMiddleware(
            state,
            .synthesizeAudio(chapter, language),
            mockEnvironment
        )
        
        #expect(resultAction == .failedToSynthesizeAudio)
        #expect(mockEnvironment.synthesizeSpeechCalled == true)
    }
    
    @Test
    func playTranslationAudio_withChapter_returnsUpdateTranslationPlayTime() async {
        let word = WordTimeStampData.arrange(time: 10.0, duration: 2.0)
        let sentence = Sentence.arrange(timestamps: [word])
        let chapter = Chapter.arrange(sentences: [sentence])
        let state = TranslationState.arrange(chapter: chapter)
        
        let resultAction = await translationMiddleware(
            state,
            .playTranslationAudio,
            mockEnvironment
        )
        
        #expect(resultAction == .updateTranslationPlayTime)
    }
    
    @Test
    func playTranslationAudio_withoutChapter_returnsNil() async {
        let state = TranslationState.arrange(chapter: nil)
        
        let resultAction = await translationMiddleware(
            state,
            .playTranslationAudio,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func updateTranslationPlayTime_isPlaying_returnsUpdateTranslationPlayTime() async {
        let state = TranslationState.arrange(isPlayingAudio: true)
        
        let resultAction = await translationMiddleware(
            state,
            .updateTranslationPlayTime,
            mockEnvironment
        )
        
        #expect(resultAction == .updateTranslationPlayTime)
    }
    
    @Test
    func updateTranslationPlayTime_notPlaying_returnsNil() async {
        let state = TranslationState.arrange(isPlayingAudio: false)
        
        let resultAction = await translationMiddleware(
            state,
            .updateTranslationPlayTime,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func pauseTranslationAudio_returnsNil() async {
        let state = TranslationState.arrange
        
        let resultAction = await translationMiddleware(
            state,
            .pauseTranslationAudio,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func playTranslationWord_returnsUpdateTranslationPlayTime() async {
        let word = WordTimeStampData.arrange
        let state = TranslationState.arrange
        
        let resultAction = await translationMiddleware(
            state,
            .playTranslationWord(word),
            mockEnvironment
        )
        
        #expect(resultAction == .updateTranslationPlayTime)
    }
    
    @Test
    func selectTranslationWord_returnsNil() async {
        let word = WordTimeStampData.arrange
        let state = TranslationState.arrange
        
        let resultAction = await translationMiddleware(
            state,
            .selectTranslationWord(word),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func saveCurrentTranslation_success_returnsOnTranslationsSaved() async {
        let chapter = Chapter.arrange
        let state = TranslationState.arrange(chapter: chapter)
        let savedTranslations = [Chapter.arrange, Chapter.arrange]
        
        mockEnvironment.saveTranslationResult = .success(())
        mockEnvironment.loadTranslationHistoryResult = .success(savedTranslations)
        
        let resultAction = await translationMiddleware(
            state,
            .saveCurrentTranslation,
            mockEnvironment
        )
        
        #expect(resultAction == .onTranslationsSaved(savedTranslations))
        #expect(mockEnvironment.saveTranslationCalled == true)
        #expect(mockEnvironment.saveTranslationSpy == chapter)
        #expect(mockEnvironment.loadTranslationHistoryCalled == true)
    }
    
    @Test
    func saveCurrentTranslation_noChapter_returnsNil() async {
        let state = TranslationState.arrange(chapter: nil)
        
        let resultAction = await translationMiddleware(
            state,
            .saveCurrentTranslation,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.saveTranslationCalled == false)
    }
    
    @Test
    func saveCurrentTranslation_saveFails_returnsNil() async {
        let chapter = Chapter.arrange
        let state = TranslationState.arrange(chapter: chapter)
        
        mockEnvironment.saveTranslationResult = .failure(.genericError)
        
        let resultAction = await translationMiddleware(
            state,
            .saveCurrentTranslation,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.saveTranslationCalled == true)
        #expect(mockEnvironment.loadTranslationHistoryCalled == false)
    }
    
    @Test
    func loadTranslationHistory_success_returnsOnTranslationsLoaded() async {
        let translations = [Chapter.arrange, Chapter.arrange]
        mockEnvironment.loadTranslationHistoryResult = .success(translations)
        
        let resultAction = await translationMiddleware(
            .arrange,
            .loadTranslationHistory,
            mockEnvironment
        )
        
        #expect(resultAction == .onTranslationsLoaded(translations))
        #expect(mockEnvironment.loadTranslationHistoryCalled == true)
    }
    
    @Test
    func loadTranslationHistory_error_returnsEmptyList() async {
        mockEnvironment.loadTranslationHistoryResult = .failure(.genericError)
        
        let resultAction = await translationMiddleware(
            .arrange,
            .loadTranslationHistory,
            mockEnvironment
        )
        
        #expect(resultAction == .onTranslationsLoaded([]))
        #expect(mockEnvironment.loadTranslationHistoryCalled == true)
    }
    
    @Test
    func deleteTranslation_success_returnsOnTranslationsLoaded() async {
        let translationId = UUID()
        let remainingTranslations = [Chapter.arrange]
        
        mockEnvironment.deleteTranslationResult = .success(())
        mockEnvironment.loadTranslationHistoryResult = .success(remainingTranslations)
        
        let resultAction = await translationMiddleware(
            .arrange,
            .deleteTranslation(translationId),
            mockEnvironment
        )
        
        #expect(resultAction == .onTranslationsLoaded(remainingTranslations))
        #expect(mockEnvironment.deleteTranslationCalled == true)
        #expect(mockEnvironment.deleteTranslationIdSpy == translationId)
        #expect(mockEnvironment.loadTranslationHistoryCalled == true)
    }
    
    @Test
    func deleteTranslation_error_returnsNil() async {
        let translationId = UUID()
        mockEnvironment.deleteTranslationResult = .failure(.genericError)
        
        let resultAction = await translationMiddleware(
            .arrange,
            .deleteTranslation(translationId),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.deleteTranslationCalled == true)
        #expect(mockEnvironment.loadTranslationHistoryCalled == false)
    }
    
    @Test
    func onSynthesizedTranslationAudio_returnsSaveCurrentTranslation() async {
        let chapter = Chapter.arrange
        
        let resultAction = await translationMiddleware(
            .arrange,
            .onSynthesizedTranslationAudio(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .saveCurrentTranslation)
    }
    
    @Test
    func updateSourceLanguage_returnsSaveAppSettings() async {
        let resultAction = await translationMiddleware(
            .arrange,
            .updateSourceLanguage(.french),
            mockEnvironment
        )
        
        #expect(resultAction == .saveAppSettings)
    }
    
    @Test
    func updateTargetLanguage_returnsSaveAppSettings() async {
        let resultAction = await translationMiddleware(
            .arrange,
            .updateTargetLanguage(.german),
            mockEnvironment
        )
        
        #expect(resultAction == .saveAppSettings)
    }
    
    @Test
    func saveAppSettings_success_returnsOnSavedAppSettings() async {
        let settings = SettingsState.arrange
        let state = TranslationState.arrange(settings: settings)
        
        mockEnvironment.saveAppSettingsResult = .success(())
        
        let resultAction = await translationMiddleware(
            state,
            .saveAppSettings,
            mockEnvironment
        )
        
        #expect(resultAction == .onSavedAppSettings)
        #expect(mockEnvironment.saveAppSettingsCalled == true)
        #expect(mockEnvironment.saveAppSettingsSpy == settings)
    }
    
    @Test
    func saveAppSettings_error_returnsFailedToSaveAppSettings() async {
        let state = TranslationState.arrange
        
        mockEnvironment.saveAppSettingsResult = .failure(.genericError)
        
        let resultAction = await translationMiddleware(
            state,
            .saveAppSettings,
            mockEnvironment
        )
        
        #expect(resultAction == .failedToSaveAppSettings)
        #expect(mockEnvironment.saveAppSettingsCalled == true)
    }
    
    @Test
    func selectTranslation_returnsShowTextPracticeTrue() async {
        let chapter = Chapter.arrange
        
        let resultAction = await translationMiddleware(
            .arrange,
            .selectTranslation(chapter),
            mockEnvironment
        )
        
        #expect(resultAction == .showTextPractice(true))
    }
    
    // Test actions that return nil
    @Test
    func updateInputText_returnsNil() async {
        let resultAction = await translationMiddleware(
            .arrange,
            .updateInputText("test"),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func swapLanguages_returnsNil() async {
        let resultAction = await translationMiddleware(
            .arrange,
            .swapLanguages,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func translationInProgress_returnsNil() async {
        let resultAction = await translationMiddleware(
            .arrange,
            .translationInProgress(true),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func failedToSynthesizeAudio_returnsNil() async {
        let resultAction = await translationMiddleware(
            .arrange,
            .failedToSynthesizeAudio,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func failedToTranslate_setsSnackbarType() async {
        let resultAction = await translationMiddleware(
            .arrange,
            .failedToTranslate,
            mockEnvironment
        )
        
        #expect(resultAction == .setSnackbarType(.failedToWriteTranslation))
    }
    
    @Test
    func clearTranslation_returnsNil() async {
        let resultAction = await translationMiddleware(
            .arrange,
            .clearTranslation,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func onTranslationsSaved_returnsNil() async {
        let resultAction = await translationMiddleware(
            .arrange,
            .onTranslationsSaved([]),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func onTranslationsLoaded_returnsNil() async {
        let resultAction = await translationMiddleware(
            .arrange,
            .onTranslationsLoaded([]),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func onSavedAppSettings_returnsNil() async {
        let resultAction = await translationMiddleware(
            .arrange,
            .onSavedAppSettings,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func failedToSaveAppSettings_returnsNil() async {
        let resultAction = await translationMiddleware(
            .arrange,
            .failedToSaveAppSettings,
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func showTextPractice_returnsNil() async {
        let resultAction = await translationMiddleware(
            .arrange,
            .showTextPractice(true),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func refreshAppSettings_returnsNil() async {
        let resultAction = await translationMiddleware(
            .arrange,
            .refreshAppSettings(.arrange),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
    }
    
    @Test
    func setSnackbarType_callsEnvironmentAndReturnsNil() async {
        let snackbarType: SnackBarType = .failedToWriteTranslation
        
        let resultAction = await translationMiddleware(
            .arrange,
            .setSnackbarType(snackbarType),
            mockEnvironment
        )
        
        #expect(resultAction == nil)
        #expect(mockEnvironment.setSnackbarTypeCalled == true)
        #expect(mockEnvironment.setSnackbarTypeSpy == snackbarType)
    }
}
