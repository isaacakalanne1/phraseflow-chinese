//
//  TranslationMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 10/04/2025.
//

import Foundation
import ReduxKit
import AVKit

let translationMiddleware: Middleware<TranslationState, TranslationAction, TranslationEnvironmentProtocol> = { state, action, environment in
    switch action {
        case .translateText:
            let inputText = state.inputText
            guard !inputText.isEmpty else {
                return .translationInProgress(false)
            }

            // Get device and target language from settings environment
            let deviceLanguage = environment.settingsEnvironment.deviceLanguage
            let targetLanguage = state.targetLanguage

            guard let chapter = try? await environment.translateText(
                inputText,
                from: deviceLanguage,
                to: targetLanguage
            ) else {
                return .failedToTranslate
            }

            return .synthesizeAudio(chapter, state.textLanguage)

        case .breakdownText:
            let inputText = state.inputText
            guard !inputText.isEmpty else {
                return .translationInProgress(false)
            }

            // Get device language from settings environment
            let deviceLanguage = environment.settingsEnvironment.deviceLanguage

            guard let chapter = try? await environment.breakdownText(
                inputText,
                textLanguage: state.textLanguage,
                deviceLanguage: deviceLanguage
            ) else {
                return .failedToBreakdown
            }

            return .synthesizeAudio(chapter, state.targetLanguage)

        case .synthesizeAudio(let chapter, let language):
            // Get voice from settings environment
            let currentVoice = environment.settingsEnvironment.currentVoice
            let voice = currentVoice.language == language ? currentVoice : language.voices.first
            
            guard let selectedVoice = voice else {
                return .failedToBreakdown
            }

            guard let newChapter = try? await environment.synthesizeSpeech(for: chapter,
                                                                           voice: selectedVoice,
                                                                           language: language) else {
                return .failedToSynthesizeAudio
            }

            return .onSynthesizedTranslationAudio(newChapter)

        case .defineTranslationWord(let wordTimeStampData):
            return .translationDefiningInProgress(true)

        case .translationDefiningInProgress:
            let timestampData = state.currentSpokenWord

            // Check if definition already exists through environment
            // Note: This would require a method to check existing definitions
            // For now, proceed with fetching new definitions
            
            guard let sentence = state.chapter?.sentences.first,
                  let chapter = state.chapter else {
                return .failedToDefineTranslationWord
            }

            let deviceLanguage = environment.settingsEnvironment.deviceLanguage
            
            guard var definitionsForSentence = try? await environment.fetchDefinitions(
                in: sentence,
                chapter: chapter,
                deviceLanguage: deviceLanguage
            ) else {
                return .failedToDefineTranslationWord
            }

            guard var definitionOfTappedWord = definitionsForSentence.first(where: { $0.timestampData == timestampData }) else {
                return .failedToDefineTranslationWord
            }

            definitionOfTappedWord.hasBeenSeen = true
            definitionOfTappedWord.creationDate = .now

            let extractedAudio = AudioExtractor.shared.extractAudioSegment(
                from: state.audioPlayer,
                startTime: definitionOfTappedWord.timestampData.time,
                duration: definitionOfTappedWord.timestampData.duration
            )
            definitionOfTappedWord.audioData = extractedAudio

            definitionsForSentence.addDefinitions([definitionOfTappedWord])

            try? environment.saveDefinitions(definitionsForSentence)
            if let data = definitionOfTappedWord.audioData {
                try? environment.saveSentenceAudio(data, id: sentence.id)
            }

            return .onDefinedTranslationWord(definitionOfTappedWord)

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

            return .defineTranslationWord(word)

        case .onDefinedTranslationWord:
            return nil
        case .updateInputText,
                .updateSourceLanguage,
                .updateTargetLanguage,
                .updateTextLanguage,
                .updateTranslationMode,
                .swapLanguages,
                .translationInProgress,
                .onSynthesizedTranslationAudio,
                .failedToSynthesizeAudio,
                .failedToTranslate,
                .failedToBreakdown,
                .failedToDefineTranslationWord,
                .clearTranslationDefinition,
                .clearTranslation:
            return nil
        }
}
