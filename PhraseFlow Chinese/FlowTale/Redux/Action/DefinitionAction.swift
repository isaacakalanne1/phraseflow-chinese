//
//  DefinitionAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

enum DefinitionAction {
    case loadDefinitions
    case loadInitialSentenceDefinitions(Chapter)
    case onLoadedInitialDefinitions([Definition])
    case loadRemainingDefinitions(sentenceIndex: Int, previousDefinitions: [Definition])
    case onLoadedDefinitions([Definition])
    case failedToLoadDefinitions

    case onDefinedCharacter(Definition)
    case saveDefinitions
    case failedToSaveDefinitions
    
    case deleteDefinition(Definition)
    case failedToDeleteDefinition
    
    case updateStudiedWord(Definition)
    case refreshDefinitionView
    
    case clearCurrentDefinition
}
