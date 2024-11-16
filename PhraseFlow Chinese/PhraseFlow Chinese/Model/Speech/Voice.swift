//
//  Voice.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 04/11/2024.
//

import Foundation

enum Voice: String, Codable, CaseIterable, Equatable {
    case xiaoChen, xiaomo, xiaoxiao

    var title: String {
        rawValue.capitalized
    }

    var speechSynthesisVoiceName: String {
        switch self {
        case .xiaoChen:
            "zh-CN-Xiaochen:DragonHDLatestNeural"
        case .xiaomo:
            "zh-CN-XiaomoNeural"
        case .xiaoxiao:
            "zh-CN-XiaoxiaoNeural"
        }
    }

    var gender: Gender {
        switch self {
        case .xiaoChen,
                .xiaomo,
                .xiaoxiao:
                .female
        }
    }

    var defaultSpeechStyle: SpeechStyle {
        switch self {
        case .xiaoChen:
                ._default
        case .xiaomo:
                .gentle
        case .xiaoxiao:
                .lyrical
        }
    }

    var defaultSpeechRole: SpeechRole {
        ._default
    }

    var availableSpeechRoles: [SpeechRole] {
        switch self {
        case .xiaoChen:
            [
                ._default
            ]
        case .xiaomo:
            [
                ._default,
                .youngAdultFemale,
                .youngAdultMale,
                .olderAdultFemale,
                .olderAdultMale,
                .seniorFemale,
                .seniorMale,
                .girl,
                .boy
            ]
        case .xiaoxiao:
            [
                ._default
            ]
        }
    }

    var availableSpeechStyles: [SpeechStyle] {
        switch self {
        case .xiaoChen:
            [
                ._default
            ]
        case .xiaomo:
            [
                .embarrassed,
                .calm,
                .fearful,
                .cheerful,
                .disgruntled,
                .serious,
                .angry,
                .sad,
                .depressed,
                .affectionate,
                .gentle,
                .envious
            ]
        case .xiaoxiao:
            [
                .assistant,
                .chat,
                .customerService,
                .newscast,
                .affectionate,
                .angry,
                .calm,
                .cheerful,
                .disgruntled,
                .fearful,
                .gentle,
                .lyrical,
                .sad,
                .serious,
                .poetryReading,
                .friendly,
                .whispering,
                .sorry,
                .excited
            ]
        }
    }
}
