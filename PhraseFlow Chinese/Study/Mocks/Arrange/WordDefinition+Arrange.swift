//
//  WordDefinition+Arrange.swift
//  Study
//
//  Created by Isaac Akalanne on 20/09/2025.
//

import Foundation
import Study

public extension WordDefinition {
    static var arrange: WordDefinition {
        .arrange()
    }
    
    static func arrange(
        word: String = "casa",
        pronunciation: String = "KAH-sah",
        definition: String = "house",
        definitionInContextOfSentence: String = "house (a building for human habitation)"
    ) -> WordDefinition {
        .init(
            word: word,
            pronunciation: pronunciation,
            definition: definition,
            definitionInContextOfSentence: definitionInContextOfSentence
        )
    }
}
