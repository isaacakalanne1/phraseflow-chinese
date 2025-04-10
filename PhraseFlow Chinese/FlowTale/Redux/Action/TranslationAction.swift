//
//  TranslationAction.swift
//  FlowTale
//
//  Created by iakalann on 30/05/2025.
//

import Foundation

enum TranslationAction {
    case updateInputText(String)
    case updateSourceLanguage(Language?)
    case updateTargetLanguage(Language)
    case updateTextLanguage(Language)
    case updateTranslationMode(TranslationMode)
    case swapLanguages
    case translateText
    case breakdownText
    case translationInProgress(Bool)
    case onTranslated(Chapter)
    case onBrokenDown(Chapter)
    case onSynthesizedTranslationAudio(Chapter)
    case failedToTranslate
    case failedToBreakdown
    case playTranslationAudio
    case pauseTranslationAudio
    case updateTranslationPlayTime
    case selectTranslationWord(WordTimeStampData)
    case playTranslationWord(WordTimeStampData)
    case defineTranslationWord(WordTimeStampData)
    case translationDefiningInProgress(Bool)
    case onDefinedTranslationWord(Definition)
    case failedToDefineTranslationWord
    case clearTranslationDefinition
    case clearTranslation
}
