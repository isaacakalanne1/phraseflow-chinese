//
//  TranslationReducer.swift
//  FlowTale
//
//  Created by iakalann on 10/04/2025.
//

import Foundation
import ReduxKit
import AVKit

@MainActor
let translationReducer: Reducer<TranslationState, TranslationAction> = { state, action in
    var newState = state
    
    switch action {
    case .updateInputText(let text):
        newState.inputText = text
    
    case .updateSourceLanguage(let language):
        newState.settings.sourceLanguage = language
        
    case .updateTargetLanguage(let language):
        newState.settings.targetLanguage = language
        
    case .swapLanguages:
        if newState.settings.sourceLanguage != .autoDetect {
            let tempTarget = newState.settings.targetLanguage
            newState.settings.targetLanguage = newState.settings.sourceLanguage
            newState.settings.sourceLanguage = tempTarget
        }
        
    case .translateText:
        newState.isTranslating = true
        
    case .translationInProgress(let isInProgress):
        newState.isTranslating = isInProgress
    case .onSynthesizedTranslationAudio(let chapter):
        newState.chapter = chapter
        newState.isTranslating = false
        if !chapter.sentences.isEmpty {
            newState.currentSentence = chapter.sentences[0]
        }
        newState.showTextPractice = true
        
    case .failedToTranslate:
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
        
    case .clearTranslation:
        newState.inputText = ""
        newState.chapter = nil
        newState.isTranslating = false
        newState.isPlayingAudio = false
        newState.currentSpokenWord = nil
        newState.currentSentence = nil
        newState.audioPlayer.replaceCurrentItem(with: nil)
        newState.showTextPractice = false
        // Don't reset source language as it should persist between translations
        
    case .loadTranslationHistory:
        newState.isLoadingHistory = true
        
    case .onTranslationsLoaded(let translations):
        newState.savedTranslations = translations
        newState.isLoadingHistory = false
        
    case .onTranslationsSaved(let translations):
        newState.savedTranslations = translations
        
    case .refreshAppSettings(let settings):
        newState.settings = settings
        
    case .showTextPractice(let show):
        newState.showTextPractice = show
    case .selectTranslation(let chapter):
        newState.chapter = chapter
        
    case .playTranslationWord,
            .synthesizeAudio,
            .failedToSynthesizeAudio,
            .saveCurrentTranslation,
            .deleteTranslation,
            .saveAppSettings,
            .onSavedAppSettings,
            .failedToSaveAppSettings:
        break
    }
    
    return newState
}
