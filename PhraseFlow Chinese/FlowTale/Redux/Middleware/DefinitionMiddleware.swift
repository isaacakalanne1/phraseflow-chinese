//
//  DefinitionMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit

let definitionMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .definitionAction(let definitionAction):
        switch definitionAction {

        case .defineSentence(let index, _):
            do {
                guard let chapter = state.storyState.currentChapter,
                      index < chapter.sentences.count else {
                    return nil
                }
                
                let definitions = try await environment.fetchDefinitions(
                    in: chapter.sentences[index],
                    chapter: chapter,
                    deviceLanguage: state.deviceLanguage
                )

                try environment.saveDefinitions(definitions)

                return .definitionAction(.defineSentence(sentenceIndex: index + 1,
                                                         previousDefinitions: definitions))
            } catch {
                return .definitionAction(.failedToLoadDefinitions)
            }

        case .deleteDefinition(let definition):
            do {
                try environment.deleteDefinition(with: definition.id)
                return nil
            } catch {
                return .definitionAction(.failedToDeleteDefinition)
            }

        case .showDefinition(var definition, let shouldPlay):
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
            return .definitionAction(.onShownDefinition(definition, shouldPlay: shouldPlay))
        case .onShownDefinition(let definition, let shouldPlay):
            try? environment.saveDefinitions([definition])
            return shouldPlay ? .audioAction(.playWord(definition.timestampData)) : nil
        case .updateStudiedWord:
            return nil

        case .failedToLoadDefinitions,
             .failedToDeleteDefinition,
             .clearCurrentDefinition,
             .refreshDefinitionView:
            return nil
        }
    default:
        return nil
    }
}
