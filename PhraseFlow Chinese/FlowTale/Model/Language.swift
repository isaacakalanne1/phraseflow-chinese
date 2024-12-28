//
//  Language.swift
//  FlowTale
//
//  Created by iakalann on 21/11/2024.
//

import SwiftUI

enum Language: String, Codable, CaseIterable {
    case english,
         mandarinChinese,
         spanish,
         french,
         arabicGulf,
         japanese,
         korean,
         brazilianPortuguese,
         europeanPortuguese,
         hindi,
         russian,
         german

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
        let firstLetter = rawValue.prefix(1).capitalized
        let remainingLetters = rawValue.dropFirst()
        return firstLetter + remainingLetters
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
        case .english:
            LocalizedString.english
        case .hindi:
            LocalizedString.hindi
        case .german:
            LocalizedString.german
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
        case .english:
            "en-US"
        case .hindi:
            "hi-IN"
        case .german:
            "de-DE"
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
        case .europeanPortuguese,
                .brazilianPortuguese:
            "pt"
        case .english:
            "en"
        case .hindi:
            "hi"
        case .german:
            "de"
        }
    }



    var locale: Locale {
        Locale(identifier: speechCode)
    }

    var flagCodes: [String] {
        switch self {
        case .arabicGulf:
            ["ae"]
        case .mandarinChinese:
            ["cn"]
        case .french:
            ["fr"]
        case .japanese:
            ["jp"]
        case .korean:
            ["kr"]
        case .russian:
            ["ru"]
        case .spanish:
            ["es"]
        case .europeanPortuguese:
            ["pt"]
        case .brazilianPortuguese:
            ["br"]
        case .english:
            ["us"]
        case .hindi:
            ["in"]
        case .german:
            ["de"]
        }
    }

    var schemaKey: String {
        switch self {
        case .english:
            rawValue
        default:
            rawValue + "Translation"
        }
    }

    var voices: [Voice] {
        switch self {
        case .mandarinChinese:
            [.xiaoxiao,
             .yunjian]
        case .french:
            [.denise,
             .henri]
        case .japanese:
            [.mayu,
             .keita]
        case .korean:
            [.sunHi,
             .hyunsu]
        case .russian:
            [.dariya,
             .dmitry]
        case .spanish:
            [.elvira,
             .alvaro]
        case .arabicGulf:
            [.fatima,
             .hamdan]
        case .europeanPortuguese:
            [.raquel,
             .duarte]
        case .brazilianPortuguese:
            [.thalita,
             .donato]
        case .english:
            [.ava]
        case .hindi:
            [.ananya,
             .aarav]
        case .german:
            [.amala,
             .conrad]
        }
    }

    var flagEmoji: String {
        let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value
        var flags: [String] = []

        for code in flagCodes {
            let flag = code
                .uppercased()
                .unicodeScalars
                .compactMap({ UnicodeScalar(flagBase + $0.value)?.description })
                .joined()
            flags.append(flag)
        }
        return flags.reduce("") { $0 + $1 }
    }

    var alignment: Alignment {
        switch self {
        case .arabicGulf:
                .trailing
        default:
                .leading
        }
    }
}
