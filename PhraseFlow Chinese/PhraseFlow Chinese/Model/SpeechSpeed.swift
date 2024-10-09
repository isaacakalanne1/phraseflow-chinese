//
//  SpeechSpeed.swift
//  FastChinese
//
//  Created by iakalann on 08/09/2024.
//

import Foundation

enum SpeechSpeed: CaseIterable {
    case slow, normal, fast

    var title: String {
        switch self {
        case .slow:
            "Slow"
        case .normal:
            "Normal"
        case .fast:
            "Fast"
        }
    }

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
