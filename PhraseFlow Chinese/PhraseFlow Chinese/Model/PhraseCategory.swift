//
//  PhraseCategory.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 08/09/2024.
//

import Foundation

enum PhraseCategory: CaseIterable {
    case short, medium, long

    var storageKey: String {
        switch self {
        case .short:
            return "learningShortPhrases"
        case .medium:
            return "learningMediumPhrases"
        case .long:
            return "learningLongPhrases"
        }
    }
}
