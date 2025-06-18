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
                return .showSnackBarThenSaveStory(.chapterReady, story)
            }
            
        case .loadRemainingDefinitions(let chapter, let story, let sentenceIndex, let definitions):
            do {
                if sentenceIndex >= chapter.sentences.count {
                    return .definitionAction(.onLoadedDefinitions([]))
                }
                
                let sentence = chapter.sentences[sentenceIndex]
                
                let definitionsForSentence = try await environment.fetchDefinitions(
                    in: sentence,
                    story: story,
                    deviceLanguage: state.deviceLanguage ?? .english
                )

                try environment.saveDefinitions(definitionsForSentence)

                return .definitionAction(.loadRemainingDefinitions(chapter, story, sentenceIndex: sentenceIndex + 1, previousDefinitions: definitionsForSentence))
            } catch {
                return .definitionAction(.failedToLoadDefinitions)
            }
            
        case .defineSentence(let timestampData, let shouldForce):
            do {
                guard let sentence = state.storyState.sentence(containing: timestampData),
                      let story = state.storyState.currentStory else {
                    return .definitionAction(.failedToDefineSentence)
                }

                if let definition = state.definitionState.definition(timestampData: timestampData),
                   !shouldForce {
                    return .definitionAction(.onDefinedCharacter(definition))
                }

                let definitionsForSentence = try await environment.fetchDefinitions(
                    in: sentence,
                    story: story,
                    deviceLanguage: state.deviceLanguage ?? .english
                )

                guard let definitionOfTappedWord = definitionsForSentence.first(where: { $0.timestampData == timestampData }) else {
                    return .definitionAction(.failedToDefineSentence)
                }

                return .definitionAction(.onDefinedSentence(sentence,
                                          definitionsForSentence,
                                          definitionOfTappedWord))

            } catch {
                return .definitionAction(.failedToDefineSentence)
            }
            
        case .onDefinedSentence(let sentence, let definitions, var tappedDefinition):
            guard let firstWord = definitions.first?.timestampData,
                  let lastWord = definitions.last?.timestampData else {
                return .definitionAction(.saveDefinitions)
            }

            let startTime = firstWord.time
            let totalDuration = lastWord.time + lastWord.duration - startTime

            guard let sentenceAudio = AudioExtractor.shared.extractAudioSegment(
                from: state.audioState.audioPlayer,
                startTime: firstWord.time,
                duration: lastWord.time + lastWord.duration - firstWord.time
            ) else {
                return .definitionAction(.saveDefinitions)
            }

            do {
                try environment.saveSentenceAudio(sentenceAudio, id: sentence.id)
                tappedDefinition.sentenceId = sentence.id
                return .definitionAction(.onDefinedCharacter(tappedDefinition))
            } catch {
                return .definitionAction(.saveDefinitions)
            }
            
        case .onDefinedCharacter:
            return .definitionAction(.saveDefinitions)
            
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
            
        case .updateStudiedWord:
            return .definitionAction(.saveDefinitions)
            
        case .onLoadedInitialDefinitions(let definitions):
            if let currentStory = state.storyState.currentStory,
               let chapter = state.storyState.currentChapter {
                return .definitionAction(.loadRemainingDefinitions(chapter,
                                         currentStory,
                                         sentenceIndex: state.definitionState.numberOfInitialSentencesToDefine,
                                         previousDefinitions: definitions))
            }
            return .definitionAction(.refreshDefinitionView)
            
        case .onLoadedDefinitions(let definitions):
            return .definitionAction(.refreshDefinitionView)
            
        case .failedToLoadDefinitions,
             .failedToDefineSentence,
             .failedToSaveDefinitions,
             .failedToDeleteDefinition,
             .refreshDefinitionView:
            return nil
        }
    default:
        return nil
    }
}