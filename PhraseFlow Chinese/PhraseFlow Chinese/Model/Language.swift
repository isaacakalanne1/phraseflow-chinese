//
//  Language.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 21/11/2024.
//

import Foundation

enum Language: String, Codable, CaseIterable {
    case mandarinChinese, french, japanese

    var name: String {
        switch self {
        case .mandarinChinese:
            "Mandarin Chinese"
        default:
            rawValue.capitalized
        }
    }

    var schemaKey: String {
        rawValue + "Translation"
    }

    var voices: [Voice] {
        switch self {
        case .mandarinChinese:
            [.xiaoxiao,
             .xiaomo]
        case .french:
            [.vivienne]
        case .japanese:
            [.mayu]
        }
    }
}
