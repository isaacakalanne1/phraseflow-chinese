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
            prompt = "Use very short, simple sentences and very basic words."
        case .intermediate:
            prompt = "Use short, simple sentences and basic words."
        case .advanced:
            prompt = "Use medium length sentences and simple words."
        case .expert:
            prompt = ""
        }
//        prompt.append(" Use words repeatedly in this chapter, to enforce their learning by the reader.")
        return prompt
    }
}
