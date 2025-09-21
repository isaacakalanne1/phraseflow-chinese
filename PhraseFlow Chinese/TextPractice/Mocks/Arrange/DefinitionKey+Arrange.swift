//
//  DefinitionKey+Arrange.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Foundation
import TextPractice

public extension DefinitionKey {
    static var arrange: DefinitionKey {
        .arrange()
    }
    
    static func arrange(
        word: String = "word",
        sentenceId: UUID = UUID()
    ) -> DefinitionKey {
        .init(
            word: word,
            sentenceId: sentenceId
        )
    }
}