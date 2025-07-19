//
//  DefinitionMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit

let definitionMiddleware: Middleware<DefinitionState, DefinitionAction, DefinitionEnvironmentProtocol> = { state, action, environment in
    switch action {

    case .onAppear:
        do {
            let settings = try environment.getAppSettings()
            return .onLoadAppSettings(settings)
        } catch {
            return nil
        }
        
    case .onLoadAppSettings:
        return nil
        
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

            environment.viewStateEnvironment.setLoadingState(.complete)
            if index >= 1 {
                environment.definitionEnvironment.viewStateEnvironment.setIsWritingChapter(false)
            }
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
               from: state.audioState.chapterAudioPlayer,
               startTime: definition.timestampData.time,
               duration: definition.timestampData.duration
           ) {
            definition.audioData = extractedAudio
        }
        if let sentence = state.storyState.currentChapter?.currentSentence,
           let firstWord = sentence.timestamps.first,
           let lastWord = sentence.timestamps.last,
           let sentenceAudio = AudioExtractor.shared.extractAudioSegment(
               from: state.audioState.chapterAudioPlayer,
               startTime: firstWord.time,
               duration: lastWord.time + lastWord.duration - firstWord.time
           ){
            definition.sentenceId = sentence.id
            try? environment.saveSentenceAudio(sentenceAudio, id: definition.sentenceId)
        }
        return .definitionAction(.onShownDefinition(definition, shouldPlay: shouldPlay))
    case .onShownDefinition(let definition, let shouldPlay):
        try? environment.saveDefinitions([definition])
        environment.viewStateEnvironment.setIsDefining(false)
        return shouldPlay ? .audioAction(.playWord(definition.timestampData)) : nil
    case .updateStudiedWord:
        return nil

    case .refreshDefinitionView:
        environment.viewStateEnvironment.refreshDefinitionView()
        return nil
        
    case .failedToLoadDefinitions,
         .failedToDeleteDefinition,
         .clearCurrentDefinition:
        return nil
    }
}
