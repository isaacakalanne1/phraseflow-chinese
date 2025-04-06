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
            let myTime = CMTime(seconds: 0, preferredTimescale: 60000)
            await state.studyState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
            state.studyState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: definition.timestampData.duration, preferredTimescale: 60000)
            state.studyState.audioPlayer.playImmediately(atRate: state.settingsState.speechSpeed.playRate)

            return nil
        case .prepareToPlayStudySentence(let definition):
            if let audioData = try? environment.loadSentenceAudio(id: definition.sentenceId) {
                return .studyAction(.onPreparedStudySentence(audioData))
            } else {
                return .studyAction(.failedToPrepareStudySentence)
            }
        case .playStudySentence:
            let myTime = CMTime(seconds: 0, preferredTimescale: 60000)
            await state.studyState.sentenceAudioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
            state.studyState.sentenceAudioPlayer.playImmediately(atRate: state.settingsState.speechSpeed.playRate)
            return nil
        case .pauseStudyAudio:
            state.studyState.audioPlayer.pause()
            return .studyAction(.updateStudyAudioPlaying(false))
        case .failedToPrepareStudyWord,
                .failedToPrepareStudySentence,
                .onPreparedStudySentence,
                .updateStudyAudioPlaying:
            return nil
        }
    default:
        return nil
    }
}
