//
//  FastChineseAction.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

enum FastChineseAction {
    case fetchAllPhrases
    case onFetchedAllPhrases([Phrase])
    case failedToFetchAllPhrases

    case fetchAllLearningPhrases
    case onFetchedAllLearningPhrases([Phrase])
}
