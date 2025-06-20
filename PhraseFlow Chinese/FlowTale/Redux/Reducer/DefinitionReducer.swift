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
        
    case .onDefinedCharacter(var definition):
        definition.hasBeenSeen = true
        definition.creationDate = .now
        if definition.audioData == nil,
           let extractedAudio = AudioExtractor.shared.extractAudioSegment(
               from: state.audioState.audioPlayer,
               startTime: definition.timestampData.time,
               duration: definition.timestampData.duration
           ) {
            definition.audioData = extractedAudio
        }

        newState.definitionState.currentDefinition = definition
        newState.definitionState.definitions.removeAll(where: { $0.id == definition.id })
        newState.definitionState.definitions.append(definition)
        newState.viewState.isDefining = false
    case .onLoadedInitialDefinitions(let definitions):
        print("Loading \(definitions.count) initial definitions")
        newState.definitionState.definitions.addDefinitions(definitions)
        
        newState.viewState.loadingState = .complete
        newState.viewState.isWritingChapter = false

    case .loadRemainingDefinitions(_, let definitions):
        newState.definitionState.definitions.append(contentsOf: definitions)
        
    case .onLoadedDefinitions(let definitions):
        print("Loading \(definitions.count) definitions")
        print("Definitions with hasBeenSeen=true: \(definitions.filter { $0.hasBeenSeen }.count)")

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

    case .loadDefinitions,
         .loadInitialSentenceDefinitions,
         .saveDefinitions,
         .failedToLoadDefinitions,
         .failedToSaveDefinitions,
         .failedToDeleteDefinition:
        break
    }

    return newState
}
