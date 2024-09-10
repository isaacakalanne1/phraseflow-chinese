//
//  PhraseCategory.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 08/09/2024.
//

import Foundation

enum PhraseCategory: CaseIterable, Codable {
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

    var sheetId: String {
        switch self {
        case .short:
            "0"
        case .medium:
            "2033303776"
        case .long:
            "547164039"
        }
    }
}
