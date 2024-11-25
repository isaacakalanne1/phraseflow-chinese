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
         brazilianPortuguese,
         europeanPortuguese,
         russian

    var descriptiveEnglishName: String {
        switch self {
        case .brazilianPortuguese:
            "Brazilian Portuguese"
        case .europeanPortuguese:
            "European Portuguese"
        case .mandarinChinese:
            "Chinese (Mandarin)"
        case .arabicGulf:
            "Arabic (Gulf Arabic)"
        default:
            rawValue.capitalized
        }
    }

    var key: String {
        switch self {
        case .mandarinChinese:
            "MandarinChinese"
        case .arabicGulf:
            "ArabicGulf"
        case .brazilianPortuguese:
            "BrazilianPortuguese"
        case .europeanPortuguese:
            "EuropeanPortuguese"
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
        case .brazilianPortuguese:
            LocalizedString.portugueseBrazil
        case .europeanPortuguese:
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
        case .europeanPortuguese:
            "pt-PT"
        case .brazilianPortuguese:
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
        case .europeanPortuguese:
            "pt"
        case .brazilianPortuguese:
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
        case .europeanPortuguese:
            "pt"
        case .brazilianPortuguese:
            "br"
        }
    }

    var schemaKey: String {
        rawValue + "Translation"
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
        case .europeanPortuguese:
            [.raquel,
             .duarte]
        case .brazilianPortuguese:
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
