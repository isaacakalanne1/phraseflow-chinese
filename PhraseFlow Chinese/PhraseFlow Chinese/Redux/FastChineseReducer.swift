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
    case .onFetchedPhrases(let phrases):
        newState.allPhrases = phrases
    case .onAppear,
            .fetchPhrases,
            .failedToFetchPhrases:
        break
    }

    return newState
}
