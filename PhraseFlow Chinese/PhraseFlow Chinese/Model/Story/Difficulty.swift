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
        rawValue.capitalized
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
