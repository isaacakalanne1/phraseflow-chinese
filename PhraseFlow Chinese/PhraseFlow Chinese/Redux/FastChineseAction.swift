//
//  FastChineseAction.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 10/09/2024.
//

import Foundation

enum FastChineseAction {
    case onAppear
    case fetchPhrases
    case onFetchedPhrases([Phrase])
    case failedToFetchPhrases
}
