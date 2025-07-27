//
//  Voice.swift
//  FlowTale
//
//  Created by iakalann on 04/11/2024.
//

import Localization
import SwiftUI

public enum Voice: String, Codable, CaseIterable, Equatable, Sendable {
    case xiaoxiao, // Chinese
         yunjian,
         denise, // French
         henri,
         mayu, // Japanese
         keita,
         sunhi, // Korean
         hyunsu,
         dariya, // Russian
         dmitry,
         elvira, // Spanish
         alvaro,
         fatima, // Arabic
         hamdan,
         raquel, // Portuguese (Portugal)
         duarte,
         thalita, // Portuguese (Brazil)
         donato,
         ava, // English (US)
         andrew,
         sonia, // English (UK)
         ryan,
         ananya, // Hindi
         aarav,
         amala, // German
         conrad

    var title: String {
        switch self {
        case .xiaoxiao:
            return LocalizedString.voiceXiaoxiao
        case .yunjian:
            return LocalizedString.voiceYunjian
        case .denise:
            return LocalizedString.voiceDenise
        case .henri:
            return LocalizedString.voiceHenri
        case .mayu:
            return LocalizedString.voiceMayu
        case .keita:
            return LocalizedString.voiceKeita
        case .sunhi:
            return LocalizedString.voiceSunHi
        case .hyunsu:
            return LocalizedString.voiceHyunSu
        case .dariya:
            return LocalizedString.voiceDariya
        case .dmitry:
            return LocalizedString.voiceDmitry
        case .elvira:
            return LocalizedString.voiceElvira
        case .alvaro:
            return LocalizedString.voiceAlvaro
        case .fatima:
            return LocalizedString.voiceFatima
        case .hamdan:
            return LocalizedString.voiceHamdan
        case .raquel:
            return LocalizedString.voiceRaquel
        case .duarte:
            return LocalizedString.voiceDuarte
        case .thalita:
            return LocalizedString.voiceThalita
        case .donato:
            return LocalizedString.voiceDonato
        case .ava:
            return LocalizedString.voiceAva
        case .andrew:
            return LocalizedString.voiceAndrew
        case .sonia:
            return LocalizedString.voiceSonia
        case .ryan:
            return LocalizedString.voiceRyan
        case .ananya:
            return LocalizedString.voiceAnanya
        case .aarav:
            return LocalizedString.voiceAarav
        case .amala:
            return LocalizedString.voiceAmala
        case .conrad:
            return LocalizedString.voiceConrad
        }
    }

    public var speechSynthesisVoiceName: String {
        switch self {
        case .xiaoxiao:
            return "zh-CN-XiaoxiaoNeural"
        case .yunjian:
            return "zh-CN-YunjianNeural"
        case .denise:
            return "fr-FR-DeniseNeural"
        case .henri:
            return "fr-FR-HenriNeural"
        case .mayu:
            return "ja-JP-MayuNeural"
        case .keita:
            return "ja-JP-KeitaNeural"
        case .sunhi:
            return "ko-KR-SunHiNeural"
        case .hyunsu:
            return "ko-KR-HyunsuNeural"
        case .dariya:
            return "ru-RU-DariyaNeural"
        case .dmitry:
            return "ru-RU-DmitryNeural"
        case .elvira:
            return "es-ES-ElviraNeural"
        case .alvaro:
            return "es-ES-AlvaroNeural"
        case .fatima:
            return "ar-AE-FatimaNeural"
        case .hamdan:
            return "ar-AE-HamdanNeural"
        case .raquel:
            return "pt-PT-RaquelNeural"
        case .duarte:
            return "pt-PT-DuarteNeural"
        case .thalita:
            return "pt-BR-ThalitaNeural"
        case .donato:
            return "pt-BR-DonatoNeural"
        case .ava:
            return "en-US-AvaNeural"
        case .andrew:
            return "en-US-AndrewNeural"
        case .sonia:
            return "en-GB-SoniaNeural"
        case .ryan:
            return "en-GB-RyanNeural"
        case .ananya:
            return "hi-IN-AnanyaNeural"
        case .aarav:
            return "hi-IN-AaravNeural"
        case .amala:
            return "de-DE-AmalaNeural"
        case .conrad:
            return "de-DE-ConradNeural"
        }
    }

    var thumbnail: UIImage? {
        UIImage(named: "thumbnail-\(rawValue)")
    }

    public var language: Language {
        switch self {
        case .xiaoxiao,
                .yunjian:
                return .mandarinChinese
        case .denise,
                .henri:
                return .french
        case .mayu,
                .keita:
                return .japanese
        case .sunhi,
                .hyunsu:
                return .korean
        case .dariya,
                .dmitry:
                return .russian
        case .elvira,
                .alvaro:
                return .spanish
        case .fatima,
                .hamdan:
                return .arabicGulf
        case .raquel,
                .duarte:
                return .europeanPortuguese
        case .thalita,
                .donato:
                return .brazilianPortuguese
        case .ava,
                .andrew:
                return .english
        case .sonia,
                .ryan:
                return .englishUK
        case .ananya,
                .aarav:
                return .hindi
        case .amala,
                .conrad:
                return .german
        }
    }

    var gender: Gender {
        switch self {
        case .xiaoxiao,
                .denise,
                .mayu,
                .sunhi,
                .dariya,
                .elvira,
                .fatima,
                .raquel,
                .thalita,
                .ava,
                .sonia,
                .ananya,
                .amala:
                return .female
        case .yunjian,
                .henri,
                .keita,
                .alvaro,
                .hyunsu,
                .dmitry,
                .hamdan,
                .duarte,
                .donato,
                .andrew,
                .ryan,
                .aarav,
                .conrad:
                return .male
        }
    }
}
