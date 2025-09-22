//
//  TranslationReducerTests.swift
//  Translation
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Testing
import AVKit
import Foundation
import Settings
import SettingsMocks
import TextGeneration
import TextGenerationMocks
@testable import Translation
@testable import TranslationMocks

final class TranslationReducerTests {
    
    @Test
    func updateInputText_updatesInputText() {
        let initialState = TranslationState.arrange(inputText: "")
        let newText = "Hello, world!"
        
        let newState = translationReducer(
            initialState,
            .updateInputText(newText)
        )
        
        #expect(newState.inputText == newText)
    }
    
    @Test
    func updateSourceLanguage_updatesSourceLanguage() {
        let initialState = TranslationState.arrange
        let newLanguage: Language = .spanish
        
        let newState = translationReducer(
            initialState,
            .updateSourceLanguage(newLanguage)
        )
        
        #expect(newState.settings.sourceLanguage == newLanguage)
    }
    
    @Test
    func updateTargetLanguage_updatesTargetLanguage() {
        let initialState = TranslationState.arrange
        let newLanguage: Language = .french
        
        let newState = translationReducer(
            initialState,
            .updateTargetLanguage(newLanguage)
        )
        
        #expect(newState.settings.targetLanguage == newLanguage)
    }
    
    @Test
    func swapLanguages_swapsSourceAndTargetLanguages() {
        let sourceLanguage: Language = .english
        let targetLanguage: Language = .mandarinChinese
        let initialSettings = SettingsState.arrange(
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )
        let initialState = TranslationState.arrange(settings: initialSettings)
        
        let newState = translationReducer(
            initialState,
            .swapLanguages
        )
        
        #expect(newState.settings.sourceLanguage == targetLanguage)
        #expect(newState.settings.targetLanguage == sourceLanguage)
    }
    
    @Test
    func swapLanguages_withAutoDetectSource_doesNotSwap() {
        let sourceLanguage: Language = .autoDetect
        let targetLanguage: Language = .mandarinChinese
        let initialSettings = SettingsState.arrange(
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )
        let initialState = TranslationState.arrange(settings: initialSettings)
        
        let newState = translationReducer(
            initialState,
            .swapLanguages
        )
        
        #expect(newState.settings.sourceLanguage == sourceLanguage)
        #expect(newState.settings.targetLanguage == targetLanguage)
    }
    
    @Test
    func translateText_setsIsTranslatingToTrue() {
        let initialState = TranslationState.arrange(isTranslating: false)
        
        let newState = translationReducer(
            initialState,
            .translateText
        )
        
        #expect(newState.isTranslating == true)
    }
    
    @Test
    func translationInProgress_updatesIsTranslating() {
        let initialState = TranslationState.arrange(isTranslating: false)
        
        let newState = translationReducer(
            initialState,
            .translationInProgress(true)
        )
        
        #expect(newState.isTranslating == true)
    }
    
    @Test
    func onSynthesizedTranslationAudio_updatesStateCorrectly() {
        let chapter = Chapter.arrange
        let initialState = TranslationState.arrange(
            isTranslating: true,
            showTextPractice: false
        )
        
        let newState = translationReducer(
            initialState,
            .onSynthesizedTranslationAudio(chapter)
        )
        
        #expect(newState.chapter == chapter)
        #expect(newState.isTranslating == false)
        #expect(newState.showTextPractice == true)
        if !chapter.sentences.isEmpty {
            #expect(newState.currentSentence == chapter.sentences[0])
        }
    }
    
    @Test
    func failedToTranslate_setsIsTranslatingToFalse() {
        let initialState = TranslationState.arrange(isTranslating: true)
        
        let newState = translationReducer(
            initialState,
            .failedToTranslate
        )
        
        #expect(newState.isTranslating == false)
    }
    
    @Test
    func playTranslationAudio_setsIsPlayingAudioToTrue() {
        let initialState = TranslationState.arrange(isPlayingAudio: false)
        
        let newState = translationReducer(
            initialState,
            .playTranslationAudio
        )
        
        #expect(newState.isPlayingAudio == true)
    }
    
    @Test
    func pauseTranslationAudio_setsIsPlayingAudioToFalse() {
        let initialState = TranslationState.arrange(isPlayingAudio: true)
        
        let newState = translationReducer(
            initialState,
            .pauseTranslationAudio
        )
        
        #expect(newState.isPlayingAudio == false)
    }
    
    @Test
    func selectTranslationWord_updatesCurrentSpokenWordAndPlaybackTime() {
        let word = WordTimeStampData.arrange(time: 5.0)
        let initialState = TranslationState.arrange
        
        let newState = translationReducer(
            initialState,
            .selectTranslationWord(word)
        )
        
        #expect(newState.currentSpokenWord == word)
        #expect(newState.currentPlaybackTime == word.time)
    }
    
    @Test
    func clearTranslation_resetsTranslationState() {
        let initialState = TranslationState.arrange(
            inputText: "test text",
            isTranslating: true,
            chapter: .arrange,
            isPlayingAudio: true,
            currentSpokenWord: .arrange,
            currentSentence: .arrange,
            showTextPractice: true
        )
        
        let newState = translationReducer(
            initialState,
            .clearTranslation
        )
        
        #expect(newState.inputText == "")
        #expect(newState.chapter == nil)
        #expect(newState.isTranslating == false)
        #expect(newState.isPlayingAudio == false)
        #expect(newState.currentSpokenWord == nil)
        #expect(newState.currentSentence == nil)
        #expect(newState.showTextPractice == false)
    }
    
    @Test
    func onTranslationsLoaded_updatesSavedTranslations() {
        let translation1 = Chapter.arrange(id: UUID(), lastUpdated: Date().addingTimeInterval(-100))
        let translation2 = Chapter.arrange(id: UUID(), lastUpdated: Date())
        let translations = [translation1, translation2]
        let initialState = TranslationState.arrange(savedTranslations: [])
        
        let newState = translationReducer(
            initialState,
            .onTranslationsLoaded(translations)
        )
        
        #expect(newState.savedTranslations.count == 2)
        #expect(newState.savedTranslations[0] == translation2)
        #expect(newState.savedTranslations[1] == translation1)
    }
    
    @Test
    func onTranslationsSaved_updatesSavedTranslations() {
        let translation1 = Chapter.arrange(id: UUID(), lastUpdated: Date().addingTimeInterval(-100))
        let translation2 = Chapter.arrange(id: UUID(), lastUpdated: Date())
        let translations = [translation1, translation2]
        let initialState = TranslationState.arrange(savedTranslations: [])
        
        let newState = translationReducer(
            initialState,
            .onTranslationsSaved(translations)
        )
        
        #expect(newState.savedTranslations.count == 2)
        #expect(newState.savedTranslations[0] == translation2)
        #expect(newState.savedTranslations[1] == translation1)
    }
    
    @Test
    func refreshAppSettings_updatesSettings() {
        let initialSettings = SettingsState.arrange(language: .spanish)
        let newSettings = SettingsState.arrange(language: .mandarinChinese)
        let initialState = TranslationState.arrange(settings: initialSettings)
        
        let newState = translationReducer(
            initialState,
            .refreshAppSettings(newSettings)
        )
        
        #expect(newState.settings == newSettings)
    }
    
    @Test
    func showTextPractice_updatesShowTextPractice() {
        let initialState = TranslationState.arrange(showTextPractice: false)
        
        let newState = translationReducer(
            initialState,
            .showTextPractice(true)
        )
        
        #expect(newState.showTextPractice == true)
    }
    
    @Test
    func selectTranslation_updatesChapter() {
        let chapter = Chapter.arrange
        let initialState = TranslationState.arrange(chapter: nil)
        
        let newState = translationReducer(
            initialState,
            .selectTranslation(chapter)
        )
        
        #expect(newState.chapter == chapter)
    }
    
    @Test
    func playTranslationWord_doesNotChangeState() {
        let initialState = TranslationState.arrange
        
        let newState = translationReducer(
            initialState,
            .playTranslationWord(.arrange)
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func synthesizeAudio_doesNotChangeState() {
        let initialState = TranslationState.arrange
        
        let newState = translationReducer(
            initialState,
            .synthesizeAudio(.arrange, .english)
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func failedToSynthesizeAudio_doesNotChangeState() {
        let initialState = TranslationState.arrange
        
        let newState = translationReducer(
            initialState,
            .failedToSynthesizeAudio
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func saveCurrentTranslation_doesNotChangeState() {
        let initialState = TranslationState.arrange
        
        let newState = translationReducer(
            initialState,
            .saveCurrentTranslation
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func deleteTranslation_doesNotChangeState() {
        let initialState = TranslationState.arrange
        
        let newState = translationReducer(
            initialState,
            .deleteTranslation(UUID())
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func saveAppSettings_doesNotChangeState() {
        let initialState = TranslationState.arrange
        
        let newState = translationReducer(
            initialState,
            .saveAppSettings
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func onSavedAppSettings_doesNotChangeState() {
        let initialState = TranslationState.arrange
        
        let newState = translationReducer(
            initialState,
            .onSavedAppSettings
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func failedToSaveAppSettings_doesNotChangeState() {
        let initialState = TranslationState.arrange
        
        let newState = translationReducer(
            initialState,
            .failedToSaveAppSettings
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func loadTranslationHistory_doesNotChangeState() {
        let initialState = TranslationState.arrange
        
        let newState = translationReducer(
            initialState,
            .loadTranslationHistory
        )
        
        #expect(newState == initialState)
    }
    
    @Test
    func setSnackbarType_doesNotChangeState() {
        let initialState = TranslationState.arrange
        
        let newState = translationReducer(
            initialState,
            .setSnackbarType(.failedToWriteTranslation)
        )
        
        #expect(newState == initialState)
    }
}
