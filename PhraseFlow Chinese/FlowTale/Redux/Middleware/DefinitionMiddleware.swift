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
        case .loadDefinitions:
            do {
                let definitions = try environment.loadDefinitions()
                return .definitionAction(.onLoadedDefinitions(definitions))
            } catch {
                return .definitionAction(.failedToLoadDefinitions)
            }
            
        case .loadInitialSentenceDefinitions(let chapter):
            do {
                var allDefinitions: [Definition] = []
                
                for sentence in Array(chapter.sentences.prefix(3)) {
                    allDefinitions.append(contentsOf:
                                            try await environment.fetchDefinitions(
                                                in: sentence,
                                                chapter: chapter,
                                                deviceLanguage: state.deviceLanguage
                                            )
                    )
                }
                try environment.saveDefinitions(allDefinitions)

                return .definitionAction(.onLoadedInitialDefinitions(allDefinitions))
            } catch {
                return .snackbarAction(.showSnackBar(.chapterReady))
            }

        case .onLoadedInitialDefinitions(let definitions):
            return .definitionAction(.loadRemainingDefinitions(sentenceIndex: state.definitionState.numberOfInitialSentencesToDefine,
                                                               previousDefinitions: definitions))

        case .loadRemainingDefinitions(let sentenceIndex, _):
            do {
                guard let chapter = state.storyState.currentChapter,
                      sentenceIndex < chapter.sentences.count else {
                    return nil
                }
                
                // Use chapter directly with updated fetchDefinitions API
                
                let definitions = try await environment.fetchDefinitions(
                    in: chapter.sentences[sentenceIndex],
                    chapter: chapter,
                    deviceLanguage: state.deviceLanguage
                )

                try environment.saveDefinitions(definitions)

                return .definitionAction(.loadRemainingDefinitions(sentenceIndex: sentenceIndex + 1,
                                                                   previousDefinitions: definitions))
            } catch {
                return .definitionAction(.failedToLoadDefinitions)
            }

        case .saveDefinitions:
            do {
                try environment.saveDefinitions(state.definitionState.definitions)
                return nil
            } catch {
                return .definitionAction(.failedToSaveDefinitions)
            }

        case .deleteDefinition(let definition):
            do {
                try environment.deleteDefinition(with: definition.id)
                return nil
            } catch {
                return .definitionAction(.failedToDeleteDefinition)
            }

        case .onDefinedCharacter:
            return .definitionAction(.saveDefinitions)
        case .updateStudiedWord:
            return .definitionAction(.saveDefinitions)
        case .onLoadedDefinitions(let definitions):
            return .definitionAction(.refreshDefinitionView)

        case .failedToLoadDefinitions,
             .failedToSaveDefinitions,
             .failedToDeleteDefinition,
             .clearCurrentDefinition,
             .refreshDefinitionView:
            return nil
        }
    default:
        return nil
    }
}
