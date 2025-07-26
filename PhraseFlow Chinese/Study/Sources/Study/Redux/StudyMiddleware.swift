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
        await state.audioPlayer.playAudio(playRate: 1.0)
        return nil
    case .prepareToPlayStudyWord(let definition):
        if let player = await definition.audioData?.createAVPlayer(fileExtension: "m4a") {
            return .onPreparedStudyWord(player)
        }
        return nil
    case .prepareToPlayStudySentence(let definition):
        if let audioData = try? environment.loadSentenceAudio(id: definition.sentenceId),
           let player = await audioData.createAVPlayer(fileExtension: "m4a") {
            return .onPreparedStudySentence(player)
        } else {
            return .failedToPrepareStudySentence
        }
    case .playStudySentence:
        await state.sentenceAudioPlayer.playAudio(playRate: 1.0)
        return .updateStudyAudioPlaying(true)
    case .pauseStudyAudio:
        state.audioPlayer.pause()
        state.sentenceAudioPlayer.pause()
        return .updateStudyAudioPlaying(false)
    case .onLoadAppSettings:
        return nil

    case .deleteDefinition(let definition):
        do {
            try environment.deleteDefinition(with: definition.id)
            return nil
        } catch {
            return .failedToDeleteDefinition
        }

    case .playSound(let appSound):
        environment.playSound(appSound)
        return nil
        
    case .failedToDeleteDefinition,
            .updateStudiedWord,
            .failedToPrepareStudyWord,
            .failedToPrepareStudySentence,
            .onPreparedStudySentence,
            .updateDisplayStatus,
            .updateStudyAudioPlaying,
            .onPreparedStudyWord:
        return nil
    }
}
