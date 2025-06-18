//
//  TranslationMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 10/04/2025.
//

import Foundation
import ReduxKit
import AVKit

let translationMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .translationAction(let translationAction):
        switch translationAction {
        case .translateText:
            let inputText = state.translationState.inputText
            guard !inputText.isEmpty else {
                return .translationAction(.translationInProgress(false))
            }

            guard let chapter = try? await environment.translateText(
                inputText,
                from: state.deviceLanguage,
                to: state.settingsState.language
            ) else {
                return .translationAction(.failedToTranslate)
            }

            return .translationAction(.onTranslated(chapter))

        case .breakdownText:
            let inputText = state.translationState.inputText
            guard !inputText.isEmpty else {
                return .translationAction(.translationInProgress(false))
            }
            
            let textLanguage = state.translationState.textLanguage
            guard let deviceLanguage = state.deviceLanguage else {
                return .translationAction(.failedToBreakdown)
            }

            guard let chapter = try? await environment.breakdownText(
                inputText,
                textLanguage: textLanguage,
                deviceLanguage: deviceLanguage
            ) else {
                return .translationAction(.failedToBreakdown)
            }

            return .translationAction(.onBrokenDown(chapter))

        case .onBrokenDown(let chapter):
            let textLanguage = state.translationState.textLanguage
            let story = Story(language: textLanguage)

            guard let voice = state.settingsState.voice.language == textLanguage ? state.settingsState.voice : textLanguage.voices.first else {
                return .translationAction(.failedToBreakdown)
            }

            guard let newChapter = try? await environment.synthesizeSpeech(for: chapter, story: story, voice: voice, language: textLanguage) else {
                return .translationAction(.failedToBreakdown)
            }

            return .translationAction(.onSynthesizedTranslationAudio(newChapter))

        case .onTranslated(let chapter):
            let targetLanguage = state.settingsState.language
            let story = Story(language: targetLanguage)

            guard let voice = state.settingsState.voice.language == targetLanguage ? state.settingsState.voice : targetLanguage.voices.first else {
                return .translationAction(.failedToTranslate)
            }

            guard let newChapter = try? await environment.synthesizeSpeech(for: chapter, story: story, voice: voice, language: targetLanguage) else {
                return .translationAction(.failedToTranslate)
            }

            return .translationAction(.onSynthesizedTranslationAudio(newChapter))

        case .defineTranslationWord(let wordTimeStampData):
            return .translationAction(.translationDefiningInProgress(true))

        case .translationDefiningInProgress:

            let timestampData = state.translationState.currentSpokenWord

            if let existingDefinition = state.definitionState.definition(timestampData: timestampData) {
                return .translationAction(.onDefinedTranslationWord(existingDefinition))
            }

            guard let sentence = state.translationState.chapter?.sentences.first,
                  var definitionsForSentence = try? await environment.fetchDefinitions(
                in: sentence,
                story: .init(language: state.settingsState.language),
                deviceLanguage: state.deviceLanguage ?? .english
            ) else {
                return .translationAction(.failedToDefineTranslationWord)
            }

            guard var definitionOfTappedWord = definitionsForSentence.first(where: { $0.timestampData == timestampData }) else {
                return .translationAction(.failedToDefineTranslationWord)
            }

            definitionOfTappedWord.hasBeenSeen = true
            definitionOfTappedWord.creationDate = .now

            let extractedAudio = AudioExtractor.shared.extractAudioSegment(
                from: state.translationState.audioPlayer,
                startTime: definitionOfTappedWord.timestampData.time,
                duration: definitionOfTappedWord.timestampData.duration
            )
            definitionOfTappedWord.audioData = extractedAudio

            definitionsForSentence.addDefinitions([definitionOfTappedWord])

            var allDefinitions = state.definitionState.definitions
            allDefinitions.addDefinitions(definitionsForSentence)

            try? environment.saveDefinitions(allDefinitions)
            if let data = definitionOfTappedWord.audioData {
                try? environment.saveSentenceAudio(data, id: sentence.id)
            }

            return .translationAction(.onDefinedTranslationWord(definitionOfTappedWord))

        case .playTranslationAudio:
            if let lastWord = state.translationState.chapter?.sentences.last?.timestamps.last {
                await state.translationState.audioPlayer.playAudio(toSeconds: lastWord.time + lastWord.duration)
                return .translationAction(.updateTranslationPlayTime)
            }
            return nil

        case .updateTranslationPlayTime:
            if state.translationState.isPlayingAudio {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 second
                return .translationAction(.updateTranslationPlayTime)
            }
            return nil

        case .pauseTranslationAudio:
            state.translationState.audioPlayer.pause()
            return nil

        case .playTranslationWord(let word):
            await state.translationState.audioPlayer.playAudio(fromSeconds: word.time,
                                                               toSeconds: word.time + word.duration,
                                                               playRate: state.settingsState.speechSpeed.playRate)
            return .translationAction(.updateTranslationPlayTime)

        case .selectTranslationWord(let word):
            await state.translationState.audioPlayer.playAudio(fromSeconds: word.time,
                                                               toSeconds: word.time + word.duration,
                                                               playRate: state.settingsState.speechSpeed.playRate)

            return .translationAction(.defineTranslationWord(word))

        case .onDefinedTranslationWord:
            return .definitionAction(.loadDefinitions)
        case .updateInputText,
                .updateSourceLanguage,
                .updateTargetLanguage,
                .updateTextLanguage,
                .updateTranslationMode,
                .swapLanguages,
                .translationInProgress,
                .onSynthesizedTranslationAudio,
                .failedToTranslate,
                .failedToBreakdown,
                .failedToDefineTranslationWord,
                .clearTranslationDefinition,
                .clearTranslation:
            return nil
        }

    default:
        return nil
    }
}
