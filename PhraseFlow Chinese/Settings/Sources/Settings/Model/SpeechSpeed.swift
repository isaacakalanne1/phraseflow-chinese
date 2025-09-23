//
//  SpeechSpeed.swift
//  FlowTale
//
//  Created by iakalann on 08/09/2024.
//

import Foundation
import Localization

public enum SpeechSpeed: CaseIterable, Codable, Equatable, Sendable {
    case xslow, slow, normal, fast, xfast

    public var nextSpeed: SpeechSpeed {
        switch self {
        case .xslow:
                .slow
        case .slow:
                .normal
        case .normal:
                .fast
        case .fast:
                .xfast
        case .xfast:
                .xslow
        }
    }

    public var playRate: Float {
        switch self {
        case .xslow:
            0.5
        case .slow:
            0.75
        case .normal:
            1
        case .fast:
            1.25
        case .xfast:
            1.5
        }
    }

    public var text: String {
        "\(playRate)X"
    }
}
