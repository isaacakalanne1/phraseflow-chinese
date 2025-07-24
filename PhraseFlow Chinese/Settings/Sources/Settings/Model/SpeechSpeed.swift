//
//  SpeechSpeed.swift
//  FlowTale
//
//  Created by iakalann on 08/09/2024.
//

import Foundation
import Localization

public enum SpeechSpeed: CaseIterable, Codable, Equatable, Sendable {
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

    var nextSpeed: SpeechSpeed {
        switch self {
        case .slow:
                .normal
        case .normal:
                .fast
        case .fast:
                .slow
        }
    }

    var playRate: Float {
        switch self {
        case .slow:
            0.5
        case .normal:
            1
        case .fast:
            1.5
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

    var text: String {
        switch self {
        case .slow:
            "0.5X"
        case .normal:
            "1X"
        case .fast:
            "1.5X"
        }
    }
}
