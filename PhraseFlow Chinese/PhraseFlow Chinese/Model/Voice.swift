//
//  Voice.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 04/11/2024.
//

import Foundation

enum Voice: String, Codable, CaseIterable, Equatable {
    case xiaochen, xiaoxiao, yunxi, yunjian

    var title: String {
        rawValue.capitalized
    }

    var speechSynthesisVoiceName: String {
        switch self {
        case .xiaochen:
            "zh-CN-XiaochenNeural"
        case .xiaoxiao:
            "zh-CN-XiaoxiaoNeural"
        case .yunxi:
            "zh-CN-YunxiNeural"
        case .yunjian:
            "zh-CN-YunjianNeural"
        }
    }
    var gender: Gender {
        switch self {
        case .xiaochen, .xiaoxiao:
                .female
        case .yunxi, .yunjian:
                .male
        }
    }
}
