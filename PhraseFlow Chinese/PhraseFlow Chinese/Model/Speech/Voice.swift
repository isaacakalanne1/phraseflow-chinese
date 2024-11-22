//
//  Voice.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 04/11/2024.
//

import Foundation

enum Voice: String, Codable, CaseIterable, Equatable {
    case xiaomo, xiaoxiao, vivienne, remy, mayu, sunHi, dariya

    var title: String {
        rawValue.capitalized
    }

    var speechSynthesisVoiceName: String {
        switch self {
        case .xiaomo:
            "zh-CN-XiaomoNeural"
        case .xiaoxiao:
            "zh-CN-XiaoxiaoNeural"
        case .vivienne:
            "fr-FR-VivienneMultilingualNeural"
        case .remy:
            "fr-FR-RemyMultilingualNeural"
        case .mayu:
            "ja-JP-MayuNeural"
        case .sunHi:
            "ko-KR-SunHiNeural"
        case .dariya:
            "ru-RU-DariyaNeural"
        }
    }

    var gender: Gender {
        switch self {
        case .xiaomo,
                .xiaoxiao,
                .vivienne,
                .mayu,
                .sunHi,
                .dariya:
                .female
        case .remy:
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
