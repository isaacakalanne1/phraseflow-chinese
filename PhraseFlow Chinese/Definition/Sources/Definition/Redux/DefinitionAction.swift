//
//  DefinitionAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import Settings

enum DefinitionAction {
    case defineSentence(sentenceIndex: Int, previousDefinitions: [Definition])
    case failedToLoadDefinitions

    case showDefinition(Definition, shouldPlay: Bool)
    case onShownDefinition(Definition, shouldPlay: Bool)

    case deleteDefinition(Definition)
    case failedToDeleteDefinition
    
    case updateStudiedWord(Definition)
    case refreshDefinitionView
    
    case clearCurrentDefinition
    
    case onAppear
    case onLoadAppSettings(SettingsState)
}
