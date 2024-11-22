//
//  Language.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 21/11/2024.
//

import Foundation

enum Language: String, Codable, CaseIterable {
    case mandarinChinese, french, japanese, korean, russian, spanish

    var name: String {
        switch self {
        case .mandarinChinese:
            "Chinese (Mandarin)"
        default:
            rawValue.capitalized
        }
    }

    var code: String {
        switch self {
        case .mandarinChinese:
            "cn"
        case .french:
            "fr"
        case .japanese:
            "jp"
        case .korean:
            "kr"
        case .russian:
            "ru"
        case .spanish:
            "es"
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
        case .korean:
            [.sunHi]
        case .russian:
            [.dariya]
        case .spanish:
            [.elvira]
        }
    }
}
