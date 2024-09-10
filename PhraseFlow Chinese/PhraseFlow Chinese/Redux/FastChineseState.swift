//
//  FastChineseState.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

struct FastChineseState {
    var sheetIds: [String] = [
        "0",
        "2033303776",
        "547164039"
    ]

    var allPhrases: [Phrase] = []
    var allLearningPhrases: [Phrase] = []

    var currentPhrase: Phrase?
    var userInput: String = ""
    var viewState: PracticeViewState = .normal
}
