//
//  Phrase.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 07/09/2024.
//

import Foundation

struct Phrase: Identifiable, Codable, Equatable {
    var id = UUID() // Use a UUID for easy identification
    let mandarin: String
    let pinyin: String
    let english: String

    // Add an array to store timestamps for each character
    var characterTimestamps: [TimeInterval] = []
}
