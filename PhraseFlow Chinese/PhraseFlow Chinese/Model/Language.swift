//
//  Language.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 21/11/2024.
//

import Foundation

enum Language: String, Codable, CaseIterable {
    case arabicGulf,
         mandarinChinese,
         french,
         japanese,
         korean,
         portugueseBrazil,
         portugueseEuropean,
         russian,
         spanish

    var descriptiveName: String {
        switch self {
        case .portugueseBrazil:
            "Brazilian Portuguese"
        case .portugueseEuropean:
            "European Portuguese"
        default:
            displayName
        }
    }

    var displayName: String {
        switch self {
        case .mandarinChinese:
            "Chinese (Mandarin)"
        case .arabicGulf:
            "Arabic (Gulf Arabic)"
        case .portugueseBrazil:
            "Portuguese (Brazil)"
        case .portugueseEuropean:
            "Portuguese (European)"
        default:
            rawValue.capitalized
        }
    }

    var speechCode: String {
        switch self {
        case .arabicGulf:
            "ar-AE"
        case .mandarinChinese:
            "zh-CN"
        case .french:
            "fr-FR"
        case .japanese:
            "ja-JP"
        case .korean:
            "ko-KR"
        case .russian:
            "ru-RU"
        case .spanish:
            "es-ES"
        case .portugueseEuropean:
            "pt-PT"
        case .portugueseBrazil:
            "pt-BR"
        }
    }

    var code: String {
        switch self {
        case .arabicGulf:
            "ae"
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
        case .portugueseEuropean:
            "pt"
        case .portugueseBrazil:
            "br"
        }
    }

    var schemaKey: String {
        switch self {
        case .portugueseBrazil:
            "brazilianPortugueseTranslation"
        case .portugueseEuropean:
            "europeanPortugueseTranslation"
        default:
            rawValue + "Translation"
        }
    }

    var voices: [Voice] {
        switch self {
        case .mandarinChinese:
            [.xiaoxiao]
        case .french:
            [.denise,
             .henri]
        case .japanese:
            [.mayu,
             .keita]
        case .korean:
            [.sunHi]
        case .russian:
            [.dariya]
        case .spanish:
            [.elvira]
        case .arabicGulf:
            [.fatima]
        case .portugueseEuropean:
            [.raquel,
             .duarte]
        case .portugueseBrazil:
            [.thalita,
             .donato]
        }
    }

    var flagEmoji: String {
        let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value

        let flag = code
            .uppercased()
            .unicodeScalars
            .compactMap({ UnicodeScalar(flagBase + $0.value)?.description })
            .joined()
        return flag
    }
}
