//
//  Voice.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 04/11/2024.
//

import Foundation

enum Voice: String, Codable, CaseIterable, Equatable {
    case xiaoxiao, yunxi

    var title: String {
        rawValue.capitalized
    }

    var speechSynthesisVoiceName: String {
        switch self {
        case .xiaoxiao:
            "zh-CN-XiaoxiaoNeural"
        case .yunxi:
            "zh-CN-YunxiNeural"
        }
    }

    var gender: Gender {
        switch self {
        case .xiaoxiao:
                .female
        case .yunxi:
                .male
        }
    }

    var availableSpeechStyles: [SpeechStyle] {
        switch self {
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

        case .yunxi:
            [
                .narrationRelaxed,
                .embarrassed,
                .fearful,
                .cheerful,
                .disgruntled,
                .serious,
                .angry,
                .sad,
                .depressed,
                .chat,
                .assistant,
                .newscast
            ]
        }
    }
}
