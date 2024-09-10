//
//  FastChineseState.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import AVKit

struct FastChineseState {
    var sheetIds: [String] = [
        "0",
        "2033303776",
        "547164039"
    ]

    var allPhrases: [Phrase] = []
    var allLearningPhrases: [Phrase] = []
    var phraseIndex: Int = 0

    var currentPhrase: Phrase? {
        if !allLearningPhrases.isEmpty,
           allLearningPhrases.count > phraseIndex {
            return allLearningPhrases[phraseIndex]
        }
        return nil
    }

    var userInput: String = ""
    var viewState: PracticeViewState = .normal
    var speechSpeed: SpeechSpeed = .normal

    var audioPlayer: AVAudioPlayer?
}
