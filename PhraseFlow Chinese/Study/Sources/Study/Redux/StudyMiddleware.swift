//
//  StudyMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 06/04/2025.
//

import AVKit
import ReduxKit

@MainActor
let studyMiddleware: Middleware<StudyState, StudyAction, StudyEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .playStudyWord(let definition):
        environment.duckMusic()
        await state.audioPlayer.playAudio()
        
        let duration = definition.timestampData.duration
        try? await Task.sleep(for: .milliseconds(Int(duration * 1000)))
        environment.unduckMusic()
        return nil
    case .prepareToPlayStudyWord(let definition):
        if let player = await definition.audioData?.createAVPlayer(fileExtension: "m4a") {
            return .onPreparedStudyWord(player)
        }
        return .failedToPrepareStudyWord
    case .prepareToPlayStudySentence(let definition):
        if let audioData = try? environment.loadSentenceAudio(id: definition.sentenceId),
           let player = await audioData.createAVPlayer(fileExtension: "m4a") {
            return .onPreparedStudySentence(player)
        } else {
            return .failedToPrepareStudySentence
        }
    case .playStudySentence(let definition):
        environment.duckMusic()
        await state.sentenceAudioPlayer.playAudio()
        
        guard let first = definition.sentence.timestamps.first,
              let last = definition.sentence.timestamps.last else {
            environment.unduckMusic()
            return nil
        }
        let duration = (last.time + last.duration) - first.time
        try? await Task.sleep(for: .milliseconds(Int(duration * 1000)))
        environment.unduckMusic()
        return nil
    case .pauseStudyAudio:
        state.audioPlayer.pause()
        state.sentenceAudioPlayer.pause()
        return nil

    case .deleteDefinition(let definition):
        do {
            try environment.deleteDefinition(with: definition.id)
            return nil
        } catch {
            return .failedToDeleteDefinition
        }

    case .playSound(let appSound):
        if state.settings.shouldPlaySound {
            environment.playSound(appSound)
        }
        return nil
        
    case .loadDefinitions:
        do {
            let definitions = try environment.loadDefinitions()
            return .onLoadDefinitions(definitions)
        } catch {
            return .failedToLoadDefinitions
        }
    case .saveDefinitions(let definitions):
        do {
            try environment.saveDefinitions(definitions)
            return .onSavedDefinitions(definitions)
        } catch {
            return .failedToSaveDefinitions
        }
    case .onSavedDefinitions(let definitions):
        return .addDefinitions(definitions)
        
    case .failedToDeleteDefinition,
            .updateStudiedWord,
            .failedToPrepareStudyWord,
            .failedToPrepareStudySentence,
            .onPreparedStudySentence,
            .updateDisplayStatus,
            .onPreparedStudyWord,
            .onLoadDefinitions,
            .failedToLoadDefinitions,
            .refreshAppSettings,
            .addDefinitions,
            .failedToSaveDefinitions:
        return nil
    }
}
