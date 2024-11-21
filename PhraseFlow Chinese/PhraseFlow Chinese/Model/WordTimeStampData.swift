//
//  WordTimeStampData.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 23/10/2024.
//

import Foundation

struct WordTimeStampData: Codable, Equatable, Hashable {
    let word: String
    let time: Double
    var duration: Double
    var textOffset: Int
    var wordLength: Int
}
