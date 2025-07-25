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
            LocalizedString.voiceXiaoxiao
        case .yunjian:
            LocalizedString.voiceYunjian
        case .denise:
            LocalizedString.voiceDenise
        case .henri:
            LocalizedString.voiceHenri
        case .mayu:
            LocalizedString.voiceMayu
        case .keita:
            LocalizedString.voiceKeita
        case .sunhi:
            LocalizedString.voiceSunHi
        case .hyunsu:
            LocalizedString.voiceHyunSu
        case .dariya:
            LocalizedString.voiceDariya
        case .dmitry:
            LocalizedString.voiceDmitry
        case .elvira:
            LocalizedString.voiceElvira
        case .alvaro:
            LocalizedString.voiceAlvaro
        case .fatima:
            LocalizedString.voiceFatima
        case .hamdan:
            LocalizedString.voiceHamdan
        case .raquel:
            LocalizedString.voiceRaquel
        case .duarte:
            LocalizedString.voiceDuarte
        case .thalita:
            LocalizedString.voiceThalita
        case .donato:
            LocalizedString.voiceDonato
        case .ava:
            LocalizedString.voiceAva
        case .andrew:
            LocalizedString.voiceAndrew
        case .sonia:
            LocalizedString.voiceSonia
        case .ryan:
            LocalizedString.voiceRyan
        case .ananya:
            LocalizedString.voiceAnanya
        case .aarav:
            LocalizedString.voiceAarav
        case .amala:
            LocalizedString.voiceAmala
        case .conrad:
            LocalizedString.voiceConrad
        }
    }

    public var speechSynthesisVoiceName: String {
        switch self {
        case .xiaoxiao:
            "zh-CN-XiaoxiaoNeural"
        case .yunjian:
            "zh-CN-YunjianNeural"
        case .denise:
            "fr-FR-DeniseNeural"
        case .henri:
            "fr-FR-HenriNeural"
        case .mayu:
            "ja-JP-MayuNeural"
        case .keita:
            "ja-JP-KeitaNeural"
        case .sunhi:
            "ko-KR-SunHiNeural"
        case .hyunsu:
            "ko-KR-HyunsuNeural"
        case .dariya:
            "ru-RU-DariyaNeural"
        case .dmitry:
            "ru-RU-DmitryNeural"
        case .elvira:
            "es-ES-ElviraNeural"
        case .alvaro:
            "es-ES-AlvaroNeural"
        case .fatima:
            "ar-AE-FatimaNeural"
        case .hamdan:
            "ar-AE-HamdanNeural"
        case .raquel:
            "pt-PT-RaquelNeural"
        case .duarte:
            "pt-PT-DuarteNeural"
        case .thalita:
            "pt-BR-ThalitaNeural"
        case .donato:
            "pt-BR-DonatoNeural"
        case .ava:
            "en-US-AvaNeural"
        case .andrew:
            "en-US-AndrewNeural"
        case .sonia:
            "en-GB-SoniaNeural"
        case .ryan:
            "en-GB-RyanNeural"
        case .ananya:
            "hi-IN-AnanyaNeural"
        case .aarav:
            "hi-IN-AaravNeural"
        case .amala:
            "de-DE-AmalaNeural"
        case .conrad:
            "de-DE-ConradNeural"
        }
    }

    var thumbnail: UIImage? {
        UIImage(named: "thumbnail-\(rawValue)")
    }

    public var language: Language {
        switch self {
        case .xiaoxiao,
                .yunjian:
                .mandarinChinese
        case .denise,
                .henri:
                .french
        case .mayu,
                .keita:
                .japanese
        case .sunhi,
                .hyunsu:
                .korean
        case .dariya,
                .dmitry:
                .russian
        case .elvira,
                .alvaro:
                .spanish
        case .fatima,
                .hamdan:
                .arabicGulf
        case .raquel,
                .duarte:
                .europeanPortuguese
        case .thalita,
                .donato:
                .brazilianPortuguese
        case .ava,
                .andrew:
                .english
        case .sonia,
                .ryan:
                .englishUK
        case .ananya,
                .aarav:
                .hindi
        case .amala,
                .conrad:
                .german
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
                .female
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
                .male
        }
    }
}
