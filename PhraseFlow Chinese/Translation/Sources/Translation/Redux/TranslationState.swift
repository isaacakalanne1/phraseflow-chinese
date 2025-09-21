//
//  TranslationState.swift
//  FlowTale
//
//  Created by iakalann on 10/04/2025.
//

import Foundation
import AVKit
import Settings
import TextGeneration

public struct TranslationState: Equatable {
    var inputText: String
    var isTranslating: Bool
    var chapter: Chapter?
    var audioPlayer: AVPlayer
    var isPlayingAudio: Bool
    var currentPlaybackTime: Double
    var currentSpokenWord: WordTimeStampData?
    var settings: SettingsState
    var currentSentence: Sentence?
    var savedTranslations: [Chapter]
    var showTextPractice: Bool
    
    public init(
        inputText: String = "",
        isTranslating: Bool = false,
        chapter: Chapter? = nil,
        audioPlayer: AVPlayer = AVPlayer(),
        isPlayingAudio: Bool = false,
        currentPlaybackTime: Double = 0,
        currentSpokenWord: WordTimeStampData? = nil,
        settings: SettingsState = .init(),
        currentSentence: Sentence? = nil,
        savedTranslations: [Chapter] = [],
        showTextPractice: Bool = false
    ) {
        self.inputText = inputText
        self.isTranslating = isTranslating
        self.chapter = chapter
        self.audioPlayer = audioPlayer
        self.isPlayingAudio = isPlayingAudio
        self.currentPlaybackTime = currentPlaybackTime
        self.currentSpokenWord = currentSpokenWord
        self.settings = settings
        self.currentSentence = currentSentence
        self.savedTranslations = savedTranslations
        self.showTextPractice = showTextPractice
    }
    
    func sentence(
        containing timestampData: WordTimeStampData
    ) -> Sentence? {
        chapter?.sentences
            .first(where: {
                $0.timestamps.contains(where: { $0.id == timestampData.id })
            })
    }
}
