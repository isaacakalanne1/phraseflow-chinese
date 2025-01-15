//
//  Difficulty.swift
//  FlowTale
//
//  Created by iakalann on 17/10/2024.
//

import Foundation

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
            prompt = "Write using very short sentences only 5 words long or shorter. The sentences should still be gramatically correct, but should be extremely short, and use very simple words."
        case .intermediate:
            prompt = "Use basic, simple words and short sentences."
        case .advanced:
            prompt = "Use simple words and medium length sentences."
        case .expert:
            prompt = ""
        }
        return prompt
    }
}
