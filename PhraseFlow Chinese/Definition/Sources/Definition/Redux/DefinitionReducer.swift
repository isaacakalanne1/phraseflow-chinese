//
//  DefinitionReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit

let definitionReducer: Reducer<DefinitionState, DefinitionAction> = { state, action in
    var newState = state

    switch action {
        
    case .onShownDefinition(var definition, _):
        newState.currentDefinition = definition
        newState.definitions.removeAll(where: { $0.id == definition.id })
        newState.definitions.append(definition)
        // viewState.isDefining = false is handled at FlowTaleReducer level
        
    case .showDefinition:
        break

    case .defineSentence(let index, let definitions):
        // viewState.loadingState = .complete handled at FlowTaleReducer level
        // viewState.isWritingChapter = false handled at FlowTaleReducer level
        newState.definitions.addDefinitions(definitions)
        
    case .deleteDefinition(let definition):
        newState.definitions.removeAll(where: { $0.id == definition.id })
        
    case .updateStudiedWord(var definition):
        definition.studiedDates.append(.now)

        if let index = newState.definitions.firstIndex(where: { $0.timestampData == definition.timestampData }) {
            newState.definitions.replaceSubrange(index...index, with: [definition])
        } else {
            newState.definitions.append(definition)
        }
        
    case .refreshDefinitionView:
        // viewState.definitionViewId = UUID() handled at FlowTaleReducer level

    case .clearCurrentDefinition:
        newState.currentDefinition = nil

    case .failedToLoadDefinitions,
         .failedToDeleteDefinition:
        break
    }

    return newState
}
