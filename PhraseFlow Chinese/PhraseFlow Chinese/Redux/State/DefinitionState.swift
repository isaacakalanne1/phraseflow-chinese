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

    init(tappedWord: WordTimeStampData? = nil,
         currentDefinition: Definition? = nil) {
        self.tappedWord = tappedWord
        self.currentDefinition = currentDefinition
    }
}
