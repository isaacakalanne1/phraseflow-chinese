//
//  WordDefinition.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

struct WordDefinition: Codable, Equatable, Hashable {
    let word: String
    let pronunciation: String
    let definition: String
    let definitionInContextOfSentence: String
}
