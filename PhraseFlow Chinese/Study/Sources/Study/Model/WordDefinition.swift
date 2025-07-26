//
//  WordDefinition.swift
//  FlowTale
//
//  Created by iakalann on 17/04/2025.
//

public struct WordDefinition: Codable, Equatable, Hashable, Sendable {
    public let word: String
    public let pronunciation: String
    public let definition: String
    public let definitionInContextOfSentence: String
}
