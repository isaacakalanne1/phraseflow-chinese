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
        case .loadAllDefinitions:
            do {
                let definitions = try environment.loadDefinitions()
                return .definitionAction(.onLoadedAllDefinitions(definitions))
            } catch {
                return .definitionAction(.failedToLoadDefinitions)
            }

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

        case .showDefinition(let definition, let shouldPlay):
            return shouldPlay ? .audioAction(.playWord(definition.timestampData)) : nil
        case .updateStudiedWord:
            return nil
        case .onLoadedAllDefinitions(let definitions):
            return .definitionAction(.refreshDefinitionView)

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
