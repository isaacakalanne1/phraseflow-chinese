//
//  SpeechSpeed.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 08/09/2024.
//

import Foundation

enum SpeechSpeed {
    case slow, normal, fast

    var rate: Float {
        switch self {
        case .slow:
            0.5
        case .normal:
            1
        case .fast:
            1.5
        }
    }
}
