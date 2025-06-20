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

            return .translationAction(.synthesizeAudio(chapter, state.translationState.textLanguage))

        case .breakdownText:
            let inputText = state.translationState.inputText
            guard !inputText.isEmpty else {
                return .translationAction(.translationInProgress(false))
            }

            guard let chapter = try? await environment.breakdownText(
                inputText,
                textLanguage: state.translationState.textLanguage,
                deviceLanguage: state.deviceLanguage
            ) else {
                return .translationAction(.failedToBreakdown)
            }

            return .translationAction(.synthesizeAudio(chapter, state.settingsState.language))

        case .synthesizeAudio(let chapter, let language):

            guard let voice = state.settingsState.voice.language == language ? state.settingsState.voice : language.voices.first else {
                return .translationAction(.failedToBreakdown)
            }

            guard let newChapter = try? await environment.synthesizeSpeech(for: chapter,
                                                                           voice: voice,
                                                                           language: language) else {
                return .translationAction(.failedToSynthesizeAudio)
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
                  let chapter = state.translationState.chapter,
                  var definitionsForSentence = try? await environment.fetchDefinitions(
                in: sentence,
                chapter: chapter,
                deviceLanguage: state.deviceLanguage
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
                try? await Task.sleep(nanoseconds: 100_000_000)
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
                .failedToSynthesizeAudio,
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
