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
        switch self {
        case .beginner:
            UIImage(named: "Difficulty-Beginner")
        case .intermediate:
            UIImage(named: "Difficulty-Intermediate")
        case .advanced:
            UIImage(named: "Difficulty-Advanced")
        case .expert:
            UIImage(named: "Difficulty-Expert")
        }
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
            prompt = "This is a story for a beginner learning the language. Write using short sentences, and simple language."
        case .intermediate:
            prompt = "This is a story for a intermediate learning the language. Write using simple sentences."
        case .advanced:
            prompt = "This is a story for an advanced level learning the language. Write using simple language."
        case .expert:
            prompt = "" 
        }
        return prompt
    }
}
