//
//  FastChineseState.swift
//  FastChinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import AVKit

struct FastChineseState {
    var sentences: [Sentence] = []
    var sentenceIndex: Int = 0

    var currentSentence: Sentence? {
        if !sentences.isEmpty,
           sentences.count > sentenceIndex {
            return sentences[sentenceIndex]
        }
        return nil
    }

    var speechSpeed: SpeechSpeed = .normal
    var characterToDefine: String = ""
    var currentDefinition: Definition?

    var isShowingPinyin = true
    var isShowingEnglish = true
    var isShowingMandarin = true
    var audioPlayer = try? AVAudioPlayer(data: Data())
    var timestampData: [(word: String,
                         time: Double,
                         textOffset: Int,
                         wordLength: Int)] = []
}
