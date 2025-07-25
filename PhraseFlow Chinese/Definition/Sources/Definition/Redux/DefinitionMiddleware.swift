//
//  DefinitionMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Audio
import Foundation
import ReduxKit

@MainActor
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
        
    case .defineSentence(let index, _, let chapter, let deviceLanguage):
        do {
            guard let chapter = chapter,
                  let deviceLanguage = deviceLanguage,
                  index < chapter.sentences.count else {
                return nil
            }
            
            let definitions = try await environment.fetchDefinitions(
                in: chapter.sentences[index],
                chapter: chapter,
                deviceLanguage: deviceLanguage
            )

            try environment.saveDefinitions(definitions)

            environment.viewStateEnvironment.setLoadingStatus(.complete)
            if index >= 1 {
                environment.definitionEnvironment.viewStateEnvironment.setIsWritingChapter(false)
            }
            return .defineSentence(sentenceIndex: index + 1,
                                                     previousDefinitions: definitions,
                                                     chapter: chapter,
                                                     deviceLanguage: deviceLanguage)
        } catch {
            return .failedToLoadDefinitions
        }

    case .deleteDefinition(let definition):
        do {
            try environment.deleteDefinition(with: definition.id)
            return nil
        } catch {
            return .failedToDeleteDefinition
        }

    case .showDefinition(var definition, let shouldPlay):
        definition.hasBeenSeen = true
        definition.creationDate = .now
        // TODO: Audio extraction needs to be handled at the app level where we have access to audioState
        // if definition.audioData == nil,
        //    let extractedAudio = AudioExtractor.extractAudioSegment(
        //        from: state.audioState.chapterAudioPlayer,
        //        startTime: definition.timestampData.time,
        //        duration: definition.timestampData.duration
        //    ) {
        //     definition.audioData = extractedAudio
        // }
        // TODO: Sentence audio extraction needs access to storyState
        // if let sentence = state.storyState.currentChapter?.currentSentence,
        //    let firstWord = sentence.timestamps.first,
        //    let lastWord = sentence.timestamps.last,
        //    let sentenceAudio = AudioExtractor.extractAudioSegment(
        //        from: state.audioState.chapterAudioPlayer,
        //        startTime: firstWord.time,
        //        duration: lastWord.time + lastWord.duration - firstWord.time
        //    ){
        //     definition.sentenceId = sentence.id
        //     try? environment.saveSentenceAudio(sentenceAudio, id: definition.sentenceId)
        // }
        return .onShownDefinition(definition, shouldPlay: shouldPlay)
    case .onShownDefinition(let definition, let shouldPlay):
        try? environment.saveDefinitions([definition])
        environment.viewStateEnvironment.setIsDefining(false)
        return nil
    case .updateStudiedWord:
        return nil

    case .refreshDefinitionView:
        environment.viewStateEnvironment.refreshDefinitionView()
        return nil
        
    case .playSound(let appSound):
        environment.playSound(appSound)
        
    case .failedToLoadDefinitions,
         .failedToDeleteDefinition,
         .clearCurrentDefinition:
        return nil
    }
}
