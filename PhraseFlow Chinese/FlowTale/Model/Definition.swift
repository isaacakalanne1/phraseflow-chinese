//
//  Definition.swift
//  FlowTale
//
//  Created by iakalann on 11/09/2024.
//

import Foundation

struct Definition: Codable, Equatable {
    var timestampData: WordTimeStampData
    var sentence: Sentence
    var definition: String
    var language: Language
}
