//
//  Difficulty.swift
//  FlowTale
//
//  Created by iakalann on 17/10/2024.
//

import Localization
import SwiftUI

public enum Difficulty: String, Codable, Hashable, CaseIterable, Equatable, Sendable {
    case beginner, intermediate, advanced, expert

    public var index: Int {
        switch self {
        case .beginner:
            0
        case .intermediate:
            1
        case .advanced:
            2
        case .expert:
            3
        }
    }

    var thumbnail: UIImage? {
        return UIImage(named: "difficulty-\(rawValue)")
    }

    public var title: String {
        switch self {
        case .beginner:
            LocalizedString.beginner
        case .intermediate:
            LocalizedString.intermediate
        case .advanced:
            LocalizedString.advanced
        case .expert:
            LocalizedString.expert
        }
    }

    public var vocabularyPrompt: String {
        var prompt: String
        switch self {
        case .beginner:
            prompt = "Write using simple language and simple sentences."
        case .intermediate:
            prompt = "Write using simple sentences."
        case .advanced:
            prompt = "Write using simple language."
        case .expert:
            prompt = ""
        }
        return prompt
    }
}
