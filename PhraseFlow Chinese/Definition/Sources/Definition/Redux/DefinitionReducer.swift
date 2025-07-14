//
//  DefinitionReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit

let definitionReducer: Reducer<FlowTaleState, DefinitionAction> = { state, action in
    var newState = state

    switch action {
        
    case .onShownDefinition(var definition, _):
        newState.definitionState.currentDefinition = definition
        newState.definitionState.definitions.removeAll(where: { $0.id == definition.id })
        newState.definitionState.definitions.append(definition)
        newState.viewState.isDefining = false
    case .showDefinition:
        break

    case .defineSentence(let index, let definitions):
        newState.viewState.loadingState = .complete
        if index >= 1 {
            newState.viewState.isWritingChapter = false
        }
        newState.definitionState.definitions.addDefinitions(definitions)
        
    case .deleteDefinition(let definition):
        newState.definitionState.definitions.removeAll(where: { $0.id == definition.id })
        
    case .updateStudiedWord(var definition):
        definition.studiedDates.append(.now)

        if let index = newState.definitionState.definitions.firstIndex(where: { $0.timestampData == definition.timestampData }) {
            newState.definitionState.definitions.replaceSubrange(index...index, with: [definition])
        } else {
            newState.definitionState.definitions.append(definition)
        }
        
    case .refreshDefinitionView:
        newState.viewState.definitionViewId = UUID()

    case .clearCurrentDefinition:
        newState.definitionState.currentDefinition = nil

    case .failedToLoadDefinitions,
         .failedToDeleteDefinition:
        break
    }

    return newState
}
