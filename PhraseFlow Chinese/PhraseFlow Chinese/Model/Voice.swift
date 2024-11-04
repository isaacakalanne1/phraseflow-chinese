//
//  Voice.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 04/11/2024.
//

import Foundation

enum Voice: String, CaseIterable, Equatable {
    case xiaoxiao, xiaochen, yunxi, yunjian

    var title: String {
        rawValue.capitalized
    }

    var speechSynthesisVoiceName: String {
        switch self {
        case .xiaoxiao:
            "zh-CN-XiaoxiaoNeural"
        case .xiaochen:
            "zh-CN-XiaochenNeural"
        case .yunxi:
            "zh-CN-YunxiNeural"
        case .yunjian:
            "zh-CN-YunjianNeural"
        }
    }
    var gender: Gender {
        switch self {
        case .xiaoxiao, .xiaochen:
                .female
        case .yunxi, .yunjian:
                .male
        }
    }
}
