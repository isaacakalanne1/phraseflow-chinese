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
    case .onAppear:
        return .fetchPhrases
    case .fetchPhrases:
        var allPhrases: [Phrase] = []
        for sheetId in state.sheetIds {
            do {
                let phrases = try await environment.fetchPhrases(gid: sheetId)
                allPhrases.append(contentsOf: phrases)
            } catch {
                return .failedToFetchPhrases
            }
        }
        return .onFetchedPhrases(allPhrases)
    case .onFetchedPhrases,
            .failedToFetchPhrases:
        return nil
    }
}
