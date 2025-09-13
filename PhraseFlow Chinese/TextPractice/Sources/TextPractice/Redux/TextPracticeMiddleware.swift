//
//  TextPracticeMiddleware.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import Audio
import ReduxKit
import Settings
import Study
import Foundation

@MainActor
let textPracticeMiddleware: Middleware<TextPracticeState, TextPracticeAction, TextPracticeEnvironmentProtocol> = { state, action, environment in
    switch action {
        
    case .goToNextChapter:
        environment.goToNextChapter()
        return nil
    case .setChapter(let chapter):
        return .prepareToPlayChapter
    case .prepareToPlayChapter:
        await environment.prepareToPlayChapter(state.chapter)
        return .generateDefinitions(state.chapter, sentenceIndex: 0)
    case .playChapter(let word):
        await environment.playChapter(from: word, speechSpeed: state.settings.speechSpeed)
        environment.setMusicVolume(.quiet)
        return nil
    case .pauseChapter:
        environment.pauseChapter()
        environment.setMusicVolume(.normal)
        return nil
    case .selectWord(let word, let shouldPlay):
        await environment.playWord(word, rate: state.settings.speechSpeed.playRate)
        return .showDefinition(word)
    case .saveAppSettings(let settings):
        try? environment.saveAppSettings(settings)
        return nil
    case .showDefinition(let wordTimestamp):
        // Find the definition for this word in the current sentence
        if let currentSentence = state.chapter.currentSentence {
            let key = DefinitionKey(word: wordTimestamp.word, sentenceId: currentSentence.id)
            if let definition = state.definitions[key] {
                
                // Capture necessary data outside the Task to avoid data races
                let word = wordTimestamp.word
                let wordTime = wordTimestamp.time
                let wordDuration = wordTimestamp.duration
                let sentenceId = definition.sentenceId
                let needsWordAudio = definition.audioData == nil
                let definitionCopy = definition  // Make a copy for the Task
                
                // Extract sentence timing data
                let sentenceData: (startTime: Double, duration: Double)? = {
                    guard let firstWord = currentSentence.timestamps.first,
                          let lastWord = currentSentence.timestamps.last else {
                        return nil
                    }
                    let startTime = firstWord.time
                    let endTime = lastWord.time + lastWord.duration
                    let duration = endTime - startTime
                    return (startTime, duration)
                }()
                
                // Extract audio directly since we're already on MainActor
                // This may cause a runtime warning but should work functionally
                let chapterPlayer = environment.audioEnvironment.audioPlayer.chapterAudioPlayer
                
                // Extract audio for the word if not already present
                if needsWordAudio && wordTime >= 0 && wordDuration > 0 {
                    print("Extracting word audio...")
                    let wordAudioData = await MainActor.run {
                        if let asset = chapterPlayer.currentItem?.asset {
                            return AudioExtractor.extractAudioSegment(
                                from: asset,
                                startTime: wordTime,
                                duration: wordDuration
                            )
                        }
                        print("Couldn't get asset from player for sentence")
                        return nil
                    }
                    
                    if let audioData = wordAudioData {
                        // Create a new definition with the audio data
                        var updatedDefinition = definitionCopy
                        updatedDefinition.audioData = audioData
                        try? environment.saveDefinitions([updatedDefinition])
                        print("Successfully extracted and saved word audio for: \(word)")
                    } else {
                        print("Audio extraction returned nil for word: \(word)")
                    }
                }
                
                // Extract sentence audio
                if let sentenceData = sentenceData,
                   sentenceData.startTime >= 0 && sentenceData.duration > 0 {
                    print("Extracting sentence audio...")
                    let sentenceAudioData = await MainActor.run {
                        if let asset = chapterPlayer.currentItem?.asset {
                            return AudioExtractor.extractAudioSegment(
                                from: asset,
                                startTime: sentenceData.startTime,
                                duration: sentenceData.duration
                            )
                        }
                        print("Couldn't get asset from player for sentence")
                        return nil
                    }
                    
                    if let sentenceAudio = sentenceAudioData {
                        // Save sentence audio if extracted
                        try? environment.saveSentenceAudio(
                            sentenceAudio,
                            id: sentenceId
                        )
                        print("Successfully extracted and saved sentence audio for sentence: \(sentenceId)")
                    } else {
                        print("Sentence audio extraction returned nil for sentence: \(sentenceId)")
                    }
                }
            }
        }
        return nil
    case .generateDefinitions(let chapter, let sentenceIndex):
        // Check if sentenceIndex is valid
        guard sentenceIndex < chapter.sentences.count else {
            return nil
        }
        
        let sentence = chapter.sentences[sentenceIndex]
        
        // Check if definitions already exist for all words in this sentence
        let wordsInSentence = sentence.timestamps.map { $0.word }
        let existingDefinitions = wordsInSentence.compactMap { word in
            let key = DefinitionKey(word: word, sentenceId: sentence.id)
            return state.definitions[key]
        }
        
        // If we have definitions for all words in the sentence, skip fetching
        if existingDefinitions.count == wordsInSentence.count {
            return .onGeneratedDefinitions(existingDefinitions, chapter: chapter, sentenceIndex: sentenceIndex)
        }

        do {
            let sentenceDefinitions = try await environment.studyEnvironment.fetchDefinitions(
                in: sentence,
                chapter: chapter,
                deviceLanguage: Language.deviceLanguage
            )
            try? environment.saveDefinitions(sentenceDefinitions)
            return .onGeneratedDefinitions(sentenceDefinitions, chapter: chapter, sentenceIndex: sentenceIndex)
        } catch {
            return .failedToLoadDefinitions
        }
        
    case .onGeneratedDefinitions(let definitions, let chapter, let sentenceIndex):
        let nextIndex = sentenceIndex + 1
        if nextIndex < chapter.sentences.count {
            return .generateDefinitions(chapter, sentenceIndex: nextIndex)
        }
        return nil
        
    case .playWord(let word):
        await environment.playWord(word, rate: state.settings.speechSpeed.playRate)
        return nil
        
    case .defineWord(let word):
        // Find the definition for this word in the current sentence
        if let currentSentence = state.chapter.currentSentence {
            let key = DefinitionKey(word: word.word, sentenceId: currentSentence.id)
            if let definition = state.definitions[key] {
                return .onDefinedWord(definition)
            }
        }
        return .failedToDefineWord
        
    case .updateCurrentSentence:
        return .clearDefinition
        
    case .addDefinitions,
            .setPlaybackTime,
            .refreshAppSettings,
            .hideDefinition,
            .failedToLoadDefinitions,
            .onDefinedWord,
            .failedToDefineWord,
            .clearDefinition:
        return nil
    }
}
