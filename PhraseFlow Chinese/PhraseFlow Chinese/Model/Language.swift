//
//  Language.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 21/11/2024.
//

import Foundation

enum Language: String, Codable, CaseIterable {
    case mandarinChinese,
         spanish,
         french,
         arabicGulf,
         japanese,
         korean,
         portugueseBrazil,
         portugueseEuropean,
         russian

    var descriptiveEnglishName: String {
        switch self {
        case .portugueseBrazil:
            "Brazilian Portuguese"
        case .portugueseEuropean:
            "European Portuguese"
        case .mandarinChinese:
            "Chinese (Mandarin)"
        case .arabicGulf:
            "Arabic (Gulf Arabic)"
        default:
            rawValue.capitalized
        }
    }

    var displayName: String {
        switch self {
        case .mandarinChinese:
            LocalizedString.chineseMandarin
        case .arabicGulf:
            LocalizedString.arabicGulf
        case .portugueseBrazil:
            LocalizedString.portugueseBrazil
        case .portugueseEuropean:
            LocalizedString.portugueseEuropean
        case .japanese:
            LocalizedString.japanese
        case .korean:
            LocalizedString.korean
        case .russian:
            LocalizedString.russian
        case .spanish:
            LocalizedString.spanish
        case .french:
            LocalizedString.french
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

    var identifier: String {
        switch self {
        case .arabicGulf:
            "ar"
        case .mandarinChinese:
            "zh"
        case .french:
            "fr"
        case .japanese:
            "ja"
        case .korean:
            "ko"
        case .russian:
            "ru"
        case .spanish:
            "es"
        case .portugueseEuropean:
            "pt"
        case .portugueseBrazil:
            "pt"
        }
    }

    var flagCode: String {
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

        let flag = flagCode
            .uppercased()
            .unicodeScalars
            .compactMap({ UnicodeScalar(flagBase + $0.value)?.description })
            .joined()
        return flag
    }
}
