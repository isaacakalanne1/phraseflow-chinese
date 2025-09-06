//
//  TranslationReducer.swift
//  FlowTale
//
//  Created by iakalann on 10/04/2025.
//

import Foundation
import ReduxKit
import AVKit
import Story
import TextPractice

@MainActor
let translationReducer: Reducer<TranslationState, TranslationAction> = { state, action in
    var newState = state
    
    switch action {
    case .updateInputText(let text):
        newState.inputText = text
    
    case .updateSourceLanguage(let language):
        newState.sourceLanguage = language
        
    case .updateTargetLanguage(let language):
        newState.targetLanguage = language
        
    case .updateTextLanguage(let language):
        newState.textLanguage = language
        
    case .updateTranslationMode(let mode):
        newState.mode = mode
        // Clear current translation when switching modes
        newState.chapter = nil
        newState.currentDefinition = nil
        newState.currentSpokenWord = nil
        newState.currentSentence = nil
        newState.audioPlayer.replaceCurrentItem(with: nil)
        
    case .swapLanguages:
        // Only swap if source language is not nil (not auto-detect)
        if let sourceLanguage = newState.sourceLanguage {
            let tempTarget = newState.targetLanguage
            newState.targetLanguage = sourceLanguage
            newState.sourceLanguage = tempTarget
        }
        
    case .translateText,
            .breakdownText:
        newState.isTranslating = true
        
    case .translationInProgress(let isInProgress):
        newState.isTranslating = isInProgress
    case .onSynthesizedTranslationAudio(let chapter, let initialDefinitions):
        newState.chapter = chapter
        newState.isTranslating = false
        newState.currentSentenceIndex = 0
        if !chapter.sentences.isEmpty {
            newState.currentSentence = chapter.sentences[0]
        }
        // Store the initial definitions that were loaded for the first 3 sentences
        for definition in initialDefinitions {
            let key = DefinitionKey(word: definition.word, sentenceId: definition.sentenceId)
            newState.definitions[key] = definition
        }
        
    case .failedToTranslate,
            .failedToBreakdown:
        newState.isTranslating = false
        
    case .playTranslationAudio:
        newState.isPlayingAudio = true
        
    case .pauseTranslationAudio:
        newState.isPlayingAudio = false
        
    case .updateTranslationPlayTime:
        newState.currentPlaybackTime = newState.audioPlayer.currentTime().seconds
        
        // Update current word highlight based on timestamps
        if let chapter = newState.chapter {
            // Find the current spoken word across all sentences
            let allTimestamps = chapter.sentences.flatMap { $0.timestamps }
            newState.currentSpokenWord = allTimestamps.last(where: { 
                newState.currentPlaybackTime >= $0.time
            })
            
            // Update current sentence if we have a current spoken word
            if let currentWord = newState.currentSpokenWord,
               let sentence = newState.sentence(containing: currentWord),
               newState.currentSentence != sentence {
                newState.currentSentence = sentence
            }
        }
        
    case .selectTranslationWord(let word):
        newState.currentSpokenWord = word
        newState.currentPlaybackTime = word.time
        
        // Update current sentence when selecting a word
        if let sentence = newState.sentence(containing: word) {
            newState.currentSentence = sentence
        }
        
    case .onDefinedTranslationWord(let definition):
        newState.currentDefinition = definition
        
    case .clearTranslationDefinition:
        newState.currentDefinition = nil
        
    case .clearTranslation:
        newState.inputText = ""
        newState.chapter = nil
        newState.isTranslating = false
        newState.isPlayingAudio = false
        newState.currentSpokenWord = nil
        newState.currentDefinition = nil
        newState.currentSentence = nil
        newState.currentSentenceIndex = 0
        newState.definitions = [:]
        newState.audioPlayer.replaceCurrentItem(with: nil)
        // Don't reset source language as it should persist between translations
        
    case .loadTranslationHistory:
        newState.isLoadingHistory = true
        
    case .onTranslationsLoaded(let translations):
        newState.savedTranslations = translations
        newState.isLoadingHistory = false
        
    case .onTranslationsSaved(let translations):
        newState.savedTranslations = translations
        
    case .onLoadAppSettings(let settings):
        newState.targetLanguage = settings.language
        
    case .loadDefinitionsForTranslation:
        newState.isLoadingDefinitions = true
        
    case .onLoadedTranslationDefinitions(let definitions, _, _):
        for definition in definitions {
            let key = DefinitionKey(word: definition.word, sentenceId: definition.sentenceId)
            newState.definitions[key] = definition
        }
        newState.isLoadingDefinitions = false
        
    case .failedToLoadTranslationDefinitions:
        newState.isLoadingDefinitions = false
        
    case .updateCurrentSentenceIndex(let index):
        newState.currentSentenceIndex = index
        if let chapter = newState.chapter,
           index < chapter.sentences.count {
            newState.currentSentence = chapter.sentences[index]
        }
        
    case .playTranslationWord,
            .synthesizeAudio,
            .defineTranslationWord,
            .translationDefiningInProgress,
            .failedToDefineTranslationWord,
            .failedToSynthesizeAudio,
            .saveCurrentTranslation,
            .deleteTranslation,
            .loadAppSettings:
        break
    }
    
    return newState
}
