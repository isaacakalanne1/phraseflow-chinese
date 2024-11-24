//
//  Voice.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 04/11/2024.
//

import Foundation

enum Voice: String, Codable, CaseIterable, Equatable {
    case xiaomo, xiaoxiao, denise, henri, mayu, sunHi, dariya, elvira, fatima

    var title: String {
        rawValue.capitalized
    }

    var speechSynthesisVoiceName: String {
        switch self {
        case .xiaomo:
            "zh-CN-XiaomoNeural"
        case .xiaoxiao:
            "zh-CN-XiaoxiaoNeural"
        case .denise:
            "fr-FR-DeniseNeural"
        case .henri:
            "fr-FR-HenriNeural"
        case .mayu:
            "ja-JP-MayuNeural"
        case .sunHi:
            "ko-KR-SunHiNeural"
        case .dariya:
            "ru-RU-DariyaNeural"
        case .elvira:
            "es-ES-ElviraNeural"
        case .fatima:
            "ar-AE-FatimaNeural"
        }
    }

    var gender: Gender {
        switch self {
        case .xiaomo,
                .xiaoxiao,
                .denise,
                .mayu,
                .sunHi,
                .dariya,
                .elvira,
                .fatima:
                .female
        case .henri:
                .male
        }
    }

    var defaultSpeechStyle: SpeechStyle {
        switch self {
        case .xiaomo:
                .gentle
        case .xiaoxiao:
                .lyrical
        default:
                ._default
        }
    }

    var defaultSpeechRole: SpeechRole {
        ._default
    }
}
