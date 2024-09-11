//
//  PhraseCategory.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 08/09/2024.
//

import Foundation

enum PhraseCategory: CaseIterable, Codable {
    case short, medium, long

    var title: String {
        switch self {
        case .short:
            "Short"
        case .medium:
            "Medium"
        case .long:
            "Long"
        }
    }

    var quantifier: String {
        switch self {
        case .short:
            "short"
        case .medium:
            "medium length"
        case .long:
            "long"
        }
    }

    var shouldSegment: Bool {
        switch self {
        case .short,
                .medium:
            false
        case .long:
            true
        }
    }
}
