//
//  StudyMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 06/04/2025.
//

import AVKit
import ReduxKit

let studyMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .studyAction(let studyAction):
        switch studyAction {
        case .playStudyWord(let definition):
            await state.studyState.audioPlayer.playAudio(toSeconds: definition.timestampData.duration,
                                                         playRate: state.settingsState.speechSpeed.playRate)
            return nil
        case .prepareToPlayStudySentence(let definition):
            if let audioData = try? environment.loadSentenceAudio(id: definition.sentenceId) {
                return .studyAction(.onPreparedStudySentence(audioData))
            } else {
                return .studyAction(.failedToPrepareStudySentence)
            }
        case .playStudySentence:
            await state.studyState.sentenceAudioPlayer.playAudio(playRate: state.settingsState.speechSpeed.playRate)
            return .studyAction(.updateStudyAudioPlaying(true))
        case .pauseStudyAudio:
            state.studyState.audioPlayer.pause()
            state.studyState.sentenceAudioPlayer.pause()
            return .studyAction(.updateStudyAudioPlaying(false))
        case .failedToPrepareStudyWord,
                .failedToPrepareStudySentence,
                .onPreparedStudySentence,
                .updateDisplayStatus,
                .updateStudyAudioPlaying:
            return nil
        }
    default:
        return nil
    }
}
