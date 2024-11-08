//
//  Voice.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 04/11/2024.
//

import Foundation

enum Voice: String, Codable, CaseIterable, Equatable {
    case xiaomo

    var title: String {
        rawValue.capitalized
    }

    var speechSynthesisVoiceName: String {
        switch self {
        case .xiaomo:
            "zh-CN-XiaomoNeural"
        }
    }

    var gender: Gender {
        switch self {
        case .xiaomo:
                .female
        }
    }

    var availableSpeechRoles: [SpeechRole] {
        switch self {
        case .xiaomo:
            [
                .youngAdultFemale,
                .youngAdultMale,
                .olderAdultFemale,
                .olderAdultMale,
                .seniorFemale,
                .seniorMale,
                .girl,
                .boy
            ]
        }
    }

    var availableSpeechStyles: [SpeechStyle] {
        switch self {
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
        }
    }
}
