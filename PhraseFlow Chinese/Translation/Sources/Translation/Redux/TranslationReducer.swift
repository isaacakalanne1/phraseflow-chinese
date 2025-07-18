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
    case .onSynthesizedTranslationAudio(let chapter):
        newState.chapter = chapter
        let player = chapter.audio.data.createAVPlayer()
        newState.audioPlayer = player ?? AVPlayer()
        newState.isTranslating = false
        
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
        newState.audioPlayer.replaceCurrentItem(with: nil)
        // Don't reset source language as it should persist between translations
    case .playTranslationWord,
            .synthesizeAudio,
            .defineTranslationWord,
            .translationDefiningInProgress,
            .failedToDefineTranslationWord,
            .failedToSynthesizeAudio:
        break
    }
    
    return newState
}
