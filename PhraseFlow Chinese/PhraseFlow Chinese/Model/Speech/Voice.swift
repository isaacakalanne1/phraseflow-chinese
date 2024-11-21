//
//  Voice.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 04/11/2024.
//

import Foundation

enum Voice: String, Codable, CaseIterable, Equatable {
    case xiaomo, xiaoxiao, vivienne, remy

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
        }
    }

    var language: Language {
        switch self {
        case .xiaomo,
                .xiaoxiao:
                .mandarinChinese
        case .vivienne,
                .remy:
                .french
        }
    }

    var gender: Gender {
        switch self {
        case .xiaomo,
                .xiaoxiao,
                .vivienne:
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
