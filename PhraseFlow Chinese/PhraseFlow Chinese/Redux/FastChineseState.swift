//
//  FastChineseState.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import AVKit

struct FastChineseState {
    var allPhrases: [Phrase] = []
    var phraseIndex: Int = 0

    var currentPhrase: Phrase? {
        if !allPhrases.isEmpty,
           allPhrases.count > phraseIndex {
            return allPhrases[phraseIndex]
        }
        return nil
    }

    var userInput: String = ""
    var viewState: PracticeViewState = .normal
    var answerState: AnswerState = .correct
    var speechSpeed: SpeechSpeed = .normal
    var practiceMode: PracticeMode = .reading
    var characterToDefine: String = ""
    var currentDefinition: Definition = .init(character: "", phrase: .init(mandarin: "",
                                                                           pinyin: "",
                                                                           english: "",
                                                                           category: .medium), definition: "")

    var audioPlayer: AVAudioPlayer?
}
