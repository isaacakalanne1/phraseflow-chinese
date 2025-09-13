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
import UserLimit

@MainActor
let translationMiddleware: Middleware<TranslationState, TranslationAction, TranslationEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .translateText:
        let inputText = state.inputText
        guard !inputText.isEmpty else {
            return .translationInProgress(false)
        }
        
        do {
            let estimatedCharacterCount = inputText.count * 2 // Estimated characters for translation
            
            try environment.canCreateChapter(
                estimatedCharacterCount: estimatedCharacterCount,
                characterLimitPerDay: state.settings.characterLimitPerDay
            )
            
            guard let chapter = try? await environment.translateText(
                inputText,
                from: Language.deviceLanguage,
                to: state.settings.targetLanguage
            ) else {
                return .failedToTranslate
            }
            
            return .synthesizeAudio(chapter, state.settings.targetLanguage)
        } catch UserLimitsDataStoreError.freeUserCharacterLimitReached {
            environment.limitReachedSubject.send(.freeLimit)
            return .failedToTranslate // TODO: Add snackbar functionality
        } catch UserLimitsDataStoreError.characterLimitReached(let timeUntilNextAvailable) {
            environment.limitReachedSubject.send(.dailyLimit(nextAvailable: timeUntilNextAvailable))
            return .failedToTranslate // TODO: Add snackbar functionality
        } catch {
            return .failedToTranslate
        }

    case .synthesizeAudio(let chapter, let language):
        // Get voice from settings environment
        var currentVoice = state.settings.voice
        let voice = currentVoice.language == language ? currentVoice : language.voices.first
        
        guard let selectedVoice = voice else {
            return .failedToTranslate
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
        await state.audioPlayer.playAudio(fromSeconds: word.time,
                                          toSeconds: word.time + word.duration,
                                          playRate: state.settings.speechSpeed.playRate)
        return .updateTranslationPlayTime
        
    case .selectTranslationWord(let word):
        await state.audioPlayer.playAudio(fromSeconds: word.time,
                                          toSeconds: word.time + word.duration,
                                          playRate: state.settings.speechSpeed.playRate)
        return nil
        
        
    case .saveCurrentTranslation:
        guard let chapter = state.chapter else {
            return nil
        }
        
        do {
            try environment.saveTranslation(chapter)
            let updatedHistory = try environment.loadTranslationHistory()
            return .onTranslationsSaved(updatedHistory)
        } catch {
            return nil
        }
        
    case .loadTranslationHistory:
        do {
            let translations = try environment.loadTranslationHistory()
            return .onTranslationsLoaded(translations)
        } catch {
            return .onTranslationsLoaded([])
        }
        
    case .deleteTranslation(let id):
        do {
            try environment.deleteTranslation(id: id)
            let updatedHistory = try environment.loadTranslationHistory()
            return .onTranslationsLoaded(updatedHistory)
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
            .swapLanguages,
            .translationInProgress,
            .failedToSynthesizeAudio,
            .failedToTranslate,
            .clearTranslation,
            .onTranslationsSaved,
            .onTranslationsLoaded,
            .onSavedAppSettings,
            .failedToSaveAppSettings,
            .showTextPractice,
            .refreshAppSettings:
        return nil
    }
}
