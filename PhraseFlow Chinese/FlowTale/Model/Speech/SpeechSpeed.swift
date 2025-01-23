//
//  SpeechSpeed.swift
//  FlowTale
//
//  Created by iakalann on 08/09/2024.
//

import Foundation

enum SpeechSpeed: CaseIterable, Codable, Equatable {
    case slow, normal, fast

    var title: String {
        switch self {
        case .slow:
            LocalizedString.slow
        case .normal:
            LocalizedString.normal
        case .fast:
            LocalizedString.fast
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

    var emoji: String {
        switch self {
        case .slow:
            "🐌"
        case .normal:
            "🚗"
        case .fast:
            "🚀"
        }
    }
}
