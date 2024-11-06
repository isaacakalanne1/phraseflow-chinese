//
//  SpeechSpeed.swift
//  FastChinese
//
//  Created by iakalann on 08/09/2024.
//

import Foundation

enum SpeechSpeed: CaseIterable, Codable, Equatable {
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

    var rate: String {
        switch self {
        case .slow:
            "x-slow"
        case .normal:
            "medium"
        case .fast:
            "fast"
        }
    }
}
