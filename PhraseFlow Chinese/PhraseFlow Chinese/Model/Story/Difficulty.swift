//
//  Difficulty.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 17/10/2024.
//

import Foundation

enum Difficulty: String, Codable, Hashable, CaseIterable, Equatable {
    case beginner, intermediate, advanced, expert

    var maxIntValue: Int {
        10
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
}
