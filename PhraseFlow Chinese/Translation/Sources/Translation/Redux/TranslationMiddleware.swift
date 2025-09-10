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
        
        guard let (newChapter, initialDefinitions) = try? await environment.synthesizeSpeech(for: chapter,
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
        
        return .onSynthesizedTranslationAudio(newChapter, initialDefinitions: initialDefinitions)
        
    case .defineTranslationWord(let wordTimeStampData):
        return .translationDefiningInProgress(true)
        
    case .translationDefiningInProgress:
        guard let timestampData = state.currentSpokenWord else {
            return .failedToDefineTranslationWord
        }
        
        // Check if definition already exists through environment
        // Note: This would require a method to check existing definitions
        // For now, proceed with fetching new definitions
        
        guard let sentence = state.chapter?.sentences.first,
              let chapter = state.chapter else {
            return .failedToDefineTranslationWord
        }
        
        
        
        guard var definitionsForSentence = try? await environment.fetchDefinitions(
                in: sentence,
                chapter: chapter,
                deviceLanguage: Language.deviceLanguage
              ) else {
            return .failedToDefineTranslationWord
        }
        
        guard var definitionOfTappedWord = definitionsForSentence.first(where: { $0.timestampData == timestampData }) else {
            return .failedToDefineTranslationWord
        }
        
        definitionOfTappedWord.hasBeenSeen = true
        definitionOfTappedWord.creationDate = .now
        
        // Extract audio for the word
        let wordTime = timestampData.time
        let wordDuration = timestampData.duration
        let wordAudioData = AudioExtractor.extractAudioSegment(
            from: state.audioPlayer,
            startTime: wordTime,
            duration: wordDuration
        )
        definitionOfTappedWord.audioData = wordAudioData
        
        // Extract sentence audio
        if let firstWord = sentence.timestamps.first,
           let lastWord = sentence.timestamps.last {
            let sentenceStartTime = firstWord.time
            let sentenceEndTime = lastWord.time + lastWord.duration
            let sentenceDuration = sentenceEndTime - sentenceStartTime
            
            let sentenceAudioData = AudioExtractor.extractAudioSegment(
                from: state.audioPlayer,
                startTime: sentenceStartTime,
                duration: sentenceDuration
            )
            
            // Save sentence audio if extracted
            if let sentenceAudio = sentenceAudioData {
                try? environment.saveSentenceAudio(
                    sentenceAudio,
                    id: definitionOfTappedWord.sentenceId
                )
            }
        }
        
        definitionsForSentence.addDefinitions([definitionOfTappedWord])
        
        try? environment.saveDefinitions(definitionsForSentence)
        
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
        
    case .loadDefinitionsForTranslation(let chapter, let sentenceIndex):
        guard sentenceIndex < chapter.sentences.count else {
            return nil
        }
        
        let sentence = chapter.sentences[sentenceIndex]
        let existingDefinitions = sentence.timestamps.compactMap { timestamp in
            let key = DefinitionKey(word: timestamp.word, sentenceId: sentence.id)
            return state.definitions[key]
        }
        
        if existingDefinitions.count == sentence.timestamps.count {
            return .onLoadedTranslationDefinitions(existingDefinitions, chapter: chapter, sentenceIndex: sentenceIndex)
        }
        
        do {
            let definitions = try await environment.fetchDefinitions(
                in: sentence,
                chapter: chapter,
                deviceLanguage: Language.deviceLanguage
            )
            return .onLoadedTranslationDefinitions(definitions, chapter: chapter, sentenceIndex: sentenceIndex)
        } catch {
            return .failedToLoadTranslationDefinitions
        }
        
    case .onLoadedTranslationDefinitions(_, let chapter, let sentenceIndex):
        let nextIndex = sentenceIndex + 1
        if nextIndex < chapter.sentences.count {
            return .loadDefinitionsForTranslation(chapter, sentenceIndex: nextIndex)
        }
        return nil
        
    case .onSynthesizedTranslationAudio(let chapter, _):
        // Start loading from index 3 since first 3 sentences are already loaded during synthesis
        let startIndex = min(3, chapter.sentences.count)
        if startIndex < chapter.sentences.count {
            return .loadDefinitionsForTranslation(chapter, sentenceIndex: startIndex)
        }
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
            .failedToDefineTranslationWord,
            .clearTranslationDefinition,
            .clearTranslation,
            .onTranslationsSaved,
            .onTranslationsLoaded,
            .onLoadAppSettings,
            .failedToLoadTranslationDefinitions,
            .updateCurrentSentenceIndex,
            .onSavedAppSettings,
            .failedToSaveAppSettings:
        return nil
    }
}
