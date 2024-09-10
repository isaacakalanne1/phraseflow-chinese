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
    var allLearningPhrases: [Phrase] {
        allPhrases.filter({ $0.isLearning })
    }
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
