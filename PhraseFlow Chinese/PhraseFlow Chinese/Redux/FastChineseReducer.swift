//
//  FastChineseReducer.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit

let fastChineseReducer: Reducer<FastChineseState, FastChineseAction> = { state, action in
    var newState = state

    switch action {
    case .onFetchedAllPhrases(let phrases):
        newState.allPhrases = phrases
    case .onFetchedAllLearningPhrases(let phrases):
        newState.allLearningPhrases = phrases
    case .fetchAllPhrases,
            .failedToFetchAllPhrases,
            .fetchAllLearningPhrases:
        break
    }

    return newState
}
