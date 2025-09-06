//
//  DefinitionKey.swift
//  FlowTale
//
//  Created by iakalann on 16/11/2024.
//

import Foundation

public struct DefinitionKey: Hashable, Equatable {
    public let word: String
    public let sentenceId: UUID
    
    public init(word: String, sentenceId: UUID) {
        self.word = word
        self.sentenceId = sentenceId
    }
}