//
//  TranslationState.swift
//  FlowTale
//
//  Created by iakalann on 10/04/2025.
//

import Foundation
import AVKit

struct TranslationState {
    var inputText: String = ""
    var isTranslating: Bool = false
    var chapter: Chapter?
    var audioPlayer: AVPlayer = AVPlayer()
    var isPlayingAudio: Bool = false
    var currentPlaybackTime: Double = 0
    var currentSpokenWord: WordTimeStampData?
    var currentDefinition: Definition?
    var sourceLanguage: Language?
    var targetLanguage: Language = .mandarinChinese
    var currentSentence: Sentence?
    var mode: TranslationMode = .translate
    var textLanguage: Language = .mandarinChinese
    
    init() {}
    
    func sentence(containing timestampData: WordTimeStampData) -> Sentence? {
        chapter?.sentences.first(where: { $0.timestamps.contains(where: { $0.id == timestampData.id }) })
    }
}
