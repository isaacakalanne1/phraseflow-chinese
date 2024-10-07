//
//  FastChineseState.swift
//  PhraseFlow Chinese
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

    var userInput: String = ""
    var viewState: PracticeViewState = .normal
    var answerState: AnswerState = .correct
    var speechSpeed: SpeechSpeed = .normal
    var practiceMode: PracticeMode = .reading
    var characterToDefine: String = ""
    var currentDefinition: Definition?

    var audioPlayer: AVAudioPlayer?
}
