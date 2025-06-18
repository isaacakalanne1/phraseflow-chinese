//
//  DefinitionAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

enum DefinitionAction {
    case loadDefinitions
    case loadInitialSentenceDefinitions(Chapter, Story, Int)
    case onLoadedInitialDefinitions([Definition])
    case loadRemainingDefinitions(Chapter, Story, sentenceIndex: Int, previousDefinitions: [Definition])
    case onLoadedDefinitions([Definition])
    case failedToLoadDefinitions
    
    case defineSentence(WordTimeStampData, shouldForce: Bool)
    case onDefinedCharacter(Definition)
    case onDefinedSentence(Sentence, [Definition], Definition)
    case failedToDefineSentence
    case saveDefinitions
    case failedToSaveDefinitions
    
    case deleteDefinition(Definition)
    case failedToDeleteDefinition
    
    case updateStudiedWord(Definition)
    case refreshDefinitionView
}