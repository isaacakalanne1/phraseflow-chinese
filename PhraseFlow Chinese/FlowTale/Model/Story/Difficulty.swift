//
//  Difficulty.swift
//  FlowTale
//
//  Created by iakalann on 17/10/2024.
//

import SwiftUI

enum Difficulty: String, Codable, Hashable, CaseIterable, Equatable {
    case beginner, intermediate, advanced, expert

    var maxIntValue: Int {
        10
    }

    var index: Int {
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
        UIImage(named: "difficulty-\(rawValue)")
    }

    var title: String {
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

    var emoji: String {
        switch self {
        case .beginner:
            "👼"
        case .intermediate:
            "😊"
        case .advanced:
            "😎"
        case .expert:
            "😈"
        }
    }

    var intValue: Int {
        switch self {
        case .beginner:
            1
        case .intermediate:
            5
        case .advanced:
            8
        case .expert:
            maxIntValue
        }
    }

    var vocabularyPrompt: String {
        var prompt: String
        switch self {
        case .beginner:
            prompt = """
Write using short, simple sentences.
The phrases should still be gramatically correct sentences, but simply be very short.
Use an extremely limited vocabulary.

"""
        case .intermediate:
            prompt = """
Use basic, simple words and short sentences, for someone who has started learning the language, but is at intermediate level, and has basic knowledge of the language.
Use a limited vocabulary.

"""
        case .advanced:
            prompt = """
Use simple words and medium length sentences, for someone who is learning the language, but is at an advanced level, and has a great deal of vocabulary under their belt.

"""
        case .expert:
            prompt = ""
        }
        if self != .expert {
            prompt.append("Use words very repetitively, to allow the user to learn them.")
        }
        return prompt
    }
}
