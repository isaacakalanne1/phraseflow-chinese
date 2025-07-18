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
        await state.audioPlayer.playAudio(toSeconds: definition.timestampData.duration,
                                          playRate: environment.speechPlayRate)
        return nil
    case .prepareToPlayStudySentence(let definition):
        if let audioData = try? environment.loadSentenceAudio(id: definition.sentenceId) {
            return .onPreparedStudySentence(audioData)
        } else {
            return .failedToPrepareStudySentence
        }
    case .playStudySentence:
        await state.sentenceAudioPlayer.playAudio(playRate: environment.speechPlayRate)
        return .updateStudyAudioPlaying(true)
    case .pauseStudyAudio:
        state.audioPlayer.pause()
        state.sentenceAudioPlayer.pause()
        return .updateStudyAudioPlaying(false)
    case .failedToPrepareStudyWord,
            .failedToPrepareStudySentence,
            .onPreparedStudySentence,
            .updateDisplayStatus,
            .updateStudyAudioPlaying:
        return nil
    }
}
