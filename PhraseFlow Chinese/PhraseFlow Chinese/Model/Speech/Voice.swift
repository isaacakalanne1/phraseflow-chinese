//
//  Voice.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 04/11/2024.
//

import Foundation

enum Voice: String, Codable, CaseIterable, Equatable {
    case xiaoxiao, // Chinese
         yunjian,
         denise, // French
         henri,
         mayu, // Japanese
         keita,
         sunHi, // Korean
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
         donato

    var title: String {
        rawValue.capitalized
    }

    var speechSynthesisVoiceName: String {
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
        case .sunHi:
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
        }
    }

    var gender: Gender {
        switch self {
        case .xiaoxiao,
                .denise,
                .mayu,
                .sunHi,
                .dariya,
                .elvira,
                .fatima,
                .raquel,
                .thalita:
                .female
        case .yunjian,
                .henri,
                .keita,
                .alvaro,
                .hyunsu,
                .dmitry,
                .hamdan,
                .duarte,
                .donato:
                .male
        }
    }

    var defaultSpeechStyle: SpeechStyle {
        switch self {
        case .xiaoxiao:
                .lyrical
        default:
                .lyrical
        }
    }
}
