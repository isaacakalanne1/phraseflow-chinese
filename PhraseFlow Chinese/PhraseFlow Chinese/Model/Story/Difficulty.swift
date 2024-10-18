//
//  Difficulty.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 17/10/2024.
//

import Foundation

enum Difficulty: String, Codable, Hashable {
    case HSK1, HSK2, HSK3, HSK4, HSK5

    var title: String {
        rawValue.uppercased()
    }
}
