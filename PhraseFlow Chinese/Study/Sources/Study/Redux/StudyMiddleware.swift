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
    case .playStudyWord:
        await state.audioPlayer.playAudio()
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
    case .playStudySentence:
        await state.sentenceAudioPlayer.playAudio()
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
