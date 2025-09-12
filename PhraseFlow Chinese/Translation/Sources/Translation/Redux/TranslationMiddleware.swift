//
//  TranslationMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 10/04/2025.
//

import Audio
import Foundation
import ReduxKit
import AVKit
import AVFoundation
import Settings
import Story
import TextPractice

@MainActor
let translationMiddleware: Middleware<TranslationState, TranslationAction, TranslationEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .translateText:
        let inputText = state.inputText
        guard !inputText.isEmpty else {
            return .translationInProgress(false)
        }
        
        guard let chapter = try? await environment.translateText(
            inputText,
            from: Language.deviceLanguage,
            to: state.settings.targetLanguage
        ) else {
            return .failedToTranslate
        }
        
        return .synthesizeAudio(chapter, state.settings.targetLanguage)
        
    case .breakdownText:
        let inputText = state.inputText
        guard !inputText.isEmpty else {
            return .translationInProgress(false)
        }
        
        // Get device language from settings environment
        
        
        guard let chapter = try? await environment.breakdownText(
                inputText,
                textLanguage: state.settings.targetLanguage,
                deviceLanguage: Language.deviceLanguage
              ) else {
            return .failedToBreakdown
        }
        
        return .synthesizeAudio(chapter, state.settings.targetLanguage)
        
    case .synthesizeAudio(let chapter, let language):
        // Get voice from settings environment
        var currentVoice = state.settings.voice
        let voice = currentVoice.language == language ? currentVoice : language.voices.first
        
        guard let selectedVoice = voice else {
            return .failedToBreakdown
        }
        
        guard let newChapter = try? await environment.synthesizeSpeech(for: chapter,
                                                                       voice: selectedVoice,
                                                                       language: language) else {
            return .failedToSynthesizeAudio
        }
        
        let audioData = newChapter.audio.data
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempFileName = UUID().uuidString + ".m4a"
        let tempFileURL = tempDirectory.appendingPathComponent(tempFileName)
        
        do {
            try audioData.write(to: tempFileURL)
            let asset = AVAsset(url: tempFileURL)
            let playerItem = AVPlayerItem(asset: asset)
            playerItem.audioTimePitchAlgorithm = .timeDomain
            
            state.audioPlayer.replaceCurrentItem(with: playerItem)
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                try? FileManager.default.removeItem(at: tempFileURL)
            }
        } catch {
            print("Error creating AVPlayerItem from audio data: \(error)")
        }
        
        return .onSynthesizedTranslationAudio(newChapter)
        
    case .playTranslationAudio:
        if let lastWord = state.chapter?.sentences.last?.timestamps.last {
            await state.audioPlayer.playAudio(toSeconds: lastWord.time + lastWord.duration)
            return .updateTranslationPlayTime
        }
        return nil
        
    case .updateTranslationPlayTime:
        if state.isPlayingAudio {
            try? await Task.sleep(nanoseconds: 100_000_000)
            return .updateTranslationPlayTime
        }
        return nil
        
    case .pauseTranslationAudio:
        state.audioPlayer.pause()
        return nil
        
    case .playTranslationWord(let word):
        let speechSpeed = environment.settingsEnvironment.speechSpeed
        await state.audioPlayer.playAudio(fromSeconds: word.time,
                                          toSeconds: word.time + word.duration,
                                          playRate: speechSpeed.playRate)
        return .updateTranslationPlayTime
        
    case .selectTranslationWord(let word):
        let speechSpeed = environment.settingsEnvironment.speechSpeed
        await state.audioPlayer.playAudio(fromSeconds: word.time,
                                          toSeconds: word.time + word.duration,
                                          playRate: speechSpeed.playRate)
        return nil
        
        
    case .saveCurrentTranslation:
        guard let chapter = state.chapter else {
            return nil
        }
        
        do {
            try environment.translationDataStore.saveTranslation(chapter)
            let updatedHistory = try environment.translationDataStore.loadTranslationHistory()
            return .onTranslationsSaved(updatedHistory)
        } catch {
            return nil
        }
        
    case .loadTranslationHistory:
        do {
            let translations = try environment.translationDataStore.loadTranslationHistory()
            return .onTranslationsLoaded(translations)
        } catch {
            return .onTranslationsLoaded([])
        }
        
    case .deleteTranslation(let id):
        do {
            try environment.translationDataStore.deleteTranslation(id: id)
            let updatedHistory = try environment.translationDataStore.loadTranslationHistory()
            return .onTranslationsLoaded(updatedHistory)
        } catch {
            return nil
        }
        
    case .loadAppSettings:
        do {
            let settings = try environment.getAppSettings()
            return .onLoadAppSettings(settings)
        } catch {
            return nil
        }
        
    case .onSynthesizedTranslationAudio(let chapter):
        return nil
    case .updateSourceLanguage,
            .updateTargetLanguage:
        return .saveAppSettings
    case .saveAppSettings:
        do {
            try environment.saveAppSettings(state.settings)
            return .onSavedAppSettings
        } catch {
            return .failedToSaveAppSettings
        }
        
    case .updateInputText,
            .updateTranslationMode,
            .swapLanguages,
            .translationInProgress,
            .failedToSynthesizeAudio,
            .failedToTranslate,
            .failedToBreakdown,
            .clearTranslation,
            .onTranslationsSaved,
            .onTranslationsLoaded,
            .onLoadAppSettings,
            .updateCurrentSentenceIndex,
            .onSavedAppSettings,
            .failedToSaveAppSettings,
            .showTextPractice:
        return nil
    }
}
