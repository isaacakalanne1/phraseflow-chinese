//
//  Difficulty.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 17/10/2024.
//

import Foundation

enum Difficulty: String, Codable, Hashable {
    case beginner, intermediate, experienced, pro, expert

    var maxIntValue: Int {
        10
    }

    var title: String {
        rawValue.uppercased()
    }

    var intValue: Int {
        switch self {
        case .beginner:
            2
        case .intermediate:
            4
        case .experienced:
            6
        case .pro:
            8
        case .expert:
            maxIntValue
        }
    }
}
