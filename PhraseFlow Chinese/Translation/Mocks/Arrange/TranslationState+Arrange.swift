//
//  TranslationState+Arrange.swift
//  Translation
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Foundation
import AVKit
import Settings
import SettingsMocks
import TextGeneration
import TextGenerationMocks
import Translation

public extension TranslationState {
    static var arrange: TranslationState {
        .arrange()
    }
    
    static func arrange(
        inputText: String = "",
        isTranslating: Bool = false,
        chapter: Chapter? = nil,
        audioPlayer: AVPlayer = AVPlayer(),
        isPlayingAudio: Bool = false,
        currentPlaybackTime: Double = 0,
        currentSpokenWord: WordTimeStampData? = nil,
        settings: SettingsState = .arrange,
        currentSentence: Sentence? = nil,
        savedTranslations: [Chapter] = [],
        showTextPractice: Bool = false
    ) -> TranslationState {
        .init(
            inputText: inputText,
            isTranslating: isTranslating,
            chapter: chapter,
            audioPlayer: audioPlayer,
            isPlayingAudio: isPlayingAudio,
            currentPlaybackTime: currentPlaybackTime,
            currentSpokenWord: currentSpokenWord,
            settings: settings,
            currentSentence: currentSentence,
            savedTranslations: savedTranslations,
            showTextPractice: showTextPractice
        )
    }
}