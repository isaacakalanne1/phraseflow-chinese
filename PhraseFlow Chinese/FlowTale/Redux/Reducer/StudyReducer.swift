//
//  StudyReducer.swift
//  FlowTale
//
//  Created by iakalann on 22/03/2025.
//

import AVKit
import ReduxKit

let studyReducer: Reducer<StudyState, StudyAction> = { state, action in

    var newState = state
    switch action {
    case .updateStudyChapter(let chapter):
        newState.currentChapter = chapter
    case .playStudyWord,
            .playStudySentence:
        newState.audioPlayer = newState.currentChapter?.audioData?.createAVPlayer() ?? AVPlayer()
        newState.isAudioPlaying = true
    case .updateStudyAudioPlaying(let isPlaying):
        newState.isAudioPlaying = isPlaying
    case .prepareToPlayStudyWord,
            .failedToPrepareStudyWord,
            .pauseStudyAudio:
        break
    }

    return newState
}
