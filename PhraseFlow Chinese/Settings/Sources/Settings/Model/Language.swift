//
//  Language.swift
//  FlowTale
//
//  Created by iakalann on 21/11/2024.
//

import Localization
import SwiftUI

public enum Language: String, Codable, CaseIterable, Sendable {
    case english,
         englishUK,
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

    public static var deviceLanguage: Language {
        Language.allCases.first(where: { $0.identifier == Locale.current.language.languageCode?.identifier }) ?? .english
    }

    var thumbnail: UIImage? {
        return UIImage(named: "thumbnail-\(rawValue)")
    }

    public var descriptiveEnglishName: String {
        switch self {
        case .brazilianPortuguese:
            "Brazilian Portuguese"
        case .europeanPortuguese:
            "European Portuguese"
        case .mandarinChinese:
            "Chinese (Mandarin)"
        case .arabicGulf:
            "Arabic (Gulf Arabic)"
        case .english:
            "US English"
        case .englishUK:
            "UK English"
        default:
            rawValue.capitalized
        }
    }

    public var key: String {
        let firstLetter = rawValue.prefix(1).capitalized
        let remainingLetters = rawValue.dropFirst()
        return firstLetter + remainingLetters
    }

    public var displayName: String {
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
            LocalizedString.englishUS
        case .englishUK:
            LocalizedString.englishUK
        case .hindi:
            LocalizedString.hindi
        case .german:
            LocalizedString.german
        }
    }

    public var speechCode: String {
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
        case .englishUK:
            "en-GB"
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
        case .english,
             .englishUK:
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
        case .englishUK:
            ["gb"]
        case .hindi:
            ["in"]
        case .german:
            ["de"]
        }
    }

    public var schemaKey: String {
        switch self {
        case .english, .englishUK:
            rawValue + "Only"
        default:
            rawValue + "Only"
        }
    }

    public var voices: [Voice] {
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
            [.sunhi,
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
            [.ava,
             .andrew]
        case .englishUK:
            [.sonia,
             .ryan]
        case .hindi:
            [.ananya,
             .aarav]
        case .german:
            [.amala,
             .conrad]
        }
    }

    public var flagEmoji: String {
        let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value
        var flags: [String] = []

        for code in flagCodes {
            let flag = code
                .uppercased()
                .unicodeScalars
                .compactMap { UnicodeScalar(flagBase + $0.value)?.description }
                .joined()
            flags.append(flag)
        }
        return flags.reduce("") { $0 + $1 }
    }

    public var alignment: Alignment {
        switch self {
        case .arabicGulf:
            .trailing
        default:
            .leading
        }
    }
}
