//
//  StudyReducer.swift
//  FlowTale
//
//  Created by iakalann on 06/04/2025.
//

import AVKit
import ReduxKit

let studyReducer: Reducer<StudyState, StudyAction> = { state, action in
    var newState = state

    switch action {
    case .playStudyWord(let definition):
        newState.audioPlayer = definition.audioData?.createAVPlayer(fileExtension: "m4a") ?? AVPlayer()
    case .onPreparedStudySentence(let data):
        newState.sentenceAudioPlayer = data.createAVPlayer(fileExtension: "m4a") ?? AVPlayer()
    case .failedToPrepareStudySentence:
        newState.sentenceAudioPlayer = AVPlayer()
    case .updateStudyAudioPlaying(let isPlaying):
        newState.isAudioPlaying = isPlaying
    case .failedToPrepareStudyWord,
            .prepareToPlayStudySentence,
            .playStudySentence,
            .pauseStudyAudio:
        break
    }

    return newState
}
