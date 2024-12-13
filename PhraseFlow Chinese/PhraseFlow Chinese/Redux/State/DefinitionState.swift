//
//  DefinitionState.swift
//  PhraseFlow Chinese
//
//  Created by iakalann on 16/11/2024.
//

import Foundation

struct DefinitionState {
    var tappedWord: WordTimeStampData?
    var currentDefinition: Definition?
    var definitions: [Definition]

    init(tappedWord: WordTimeStampData? = nil,
         currentDefinition: Definition? = nil,
         definitions: [Definition] = []) {
        self.tappedWord = tappedWord
        self.currentDefinition = currentDefinition
        self.definitions = definitions
    }

    func definition(of word: String, in sentence: Sentence) -> Definition? {
        definitions.first(where: { $0.character == word && $0.sentence == sentence })
    }
}
