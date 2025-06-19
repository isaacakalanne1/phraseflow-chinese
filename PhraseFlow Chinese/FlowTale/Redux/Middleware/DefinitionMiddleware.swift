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
            
        case .loadInitialSentenceDefinitions(let chapter, let story, let sentenceCount):
            do {
                let initialSentences = Array(chapter.sentences.prefix(sentenceCount))
                var allDefinitions: [Definition] = []
                
                for sentence in initialSentences {
                    if let firstWord = sentence.timestamps.first {
                        let definitionsForSentence = try await environment.fetchDefinitions(
                            in: sentence,
                            story: story,
                            deviceLanguage: state.deviceLanguage ?? .english
                        )

                        try environment.saveDefinitions(definitionsForSentence)
                        allDefinitions.append(contentsOf: definitionsForSentence)
                    }
                }
                try environment.saveStory(story)

                return .definitionAction(.onLoadedInitialDefinitions(allDefinitions))
            } catch {
                return .snackbarAction(.showSnackBarThenSaveStory(.chapterReady, story))
            }

        case .onLoadedInitialDefinitions(let definitions):
            if let currentStory = state.storyState.currentStory,
               let chapter = state.storyState.currentChapter {
                return .definitionAction(.loadRemainingDefinitions(chapter,
                                         currentStory,
                                         sentenceIndex: state.definitionState.numberOfInitialSentencesToDefine,
                                         previousDefinitions: definitions))
            }
            return .definitionAction(.refreshDefinitionView)

        case .loadRemainingDefinitions(let chapter, let story, let sentenceIndex, let definitions):
            do {
                if sentenceIndex >= chapter.sentences.count {
                    return .definitionAction(.onLoadedDefinitions([]))
                }
                
                let definitions = try await environment.fetchDefinitions(
                    in: chapter.sentences[sentenceIndex],
                    story: story,
                    deviceLanguage: state.deviceLanguage
                )

                try environment.saveDefinitions(definitions)

                return .definitionAction(.loadRemainingDefinitions(chapter,
                                                                   story,
                                                                   sentenceIndex: sentenceIndex + 1,
                                                                   previousDefinitions: definitions))
            } catch {
                return .definitionAction(.failedToLoadDefinitions)
            }

        case .saveDefinitions:
            do {
                try environment.saveDefinitions(state.definitionState.definitions)
            } catch {
                return .definitionAction(.failedToSaveDefinitions)
            }
            return nil

        case .deleteDefinition(let definition):
            do {
                try environment.deleteDefinition(with: definition.id)
            } catch {
                return .definitionAction(.failedToDeleteDefinition)
            }
            return nil

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
