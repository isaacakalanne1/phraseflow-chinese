//
//  TranslationState.swift
//  FlowTale
//
//  Created by iakalann on 10/04/2025.
//

import Foundation
import AVKit
import Settings
import Study
import Story
import TextGeneration
import TextPractice

struct TranslationState: Equatable {
    var inputText: String = ""
    var isTranslating: Bool = false
    var chapter: Chapter?
    var audioPlayer: AVPlayer = AVPlayer()
    var isPlayingAudio: Bool = false
    var currentPlaybackTime: Double = 0
    var currentSpokenWord: WordTimeStampData?
    var settings: SettingsState = .init()
    var currentSentence: Sentence?
    var mode: TranslationMode = .translate
    var savedTranslations: [Chapter] = []
    var isLoadingHistory: Bool = false
    var currentSentenceIndex: Int = 0
    var showTextPractice: Bool = false
    
    init() {}
    
    func sentence(containing timestampData: WordTimeStampData) -> Sentence? {
        chapter?.sentences.first(where: { $0.timestamps.contains(where: { $0.id == timestampData.id }) })
    }
}
