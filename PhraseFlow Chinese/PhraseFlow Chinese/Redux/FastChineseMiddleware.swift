//
//  FastChineseMiddleware.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit

typealias FastChineseMiddlewareType = Middleware<FastChineseState, FastChineseAction, FastChineseEnvironmentProtocol>
let fastChineseMiddleware: FastChineseMiddlewareType = { state, action, environment in
    switch action {
    case .fetchAllPhrases:
        var allPhrases: [Phrase] = []
            do {
                for sheetId in state.sheetIds {
                    let phrases = try await environment.fetchAllPhrases(gid: sheetId)
                    allPhrases.append(contentsOf: phrases)
                }
            } catch {
                return .failedToFetchAllPhrases
            }
        return .onFetchedAllPhrases(allPhrases)
    case .fetchAllLearningPhrases:
        var learningPhrases: [Phrase] = []
        for category in PhraseCategory.allCases {
            let phrases = environment.fetchLearningPhrases(category: category)
            learningPhrases.append(contentsOf: phrases)
        }
        return .onFetchedAllLearningPhrases(learningPhrases)
    case .onFetchedAllPhrases,
            .failedToFetchAllPhrases,
            .onFetchedAllLearningPhrases:
        return nil
    }
}
