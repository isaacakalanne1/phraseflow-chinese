//
//  StudyMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 22/03/2025.
//

import ReduxKit
import AVKit

typealias StudyMiddlewareType = Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol>

let studyMiddleware: StudyMiddlewareType = { state, action, environment in
    switch action {
    case .studyAction(let studyAction):
        return await handleStudyAction(state: state, action: studyAction, environment: environment)
    default:
        return nil
    }

    func handleStudyAction(state: FlowTaleState,
                           action: StudyAction,
                           environment: FlowTaleEnvironmentProtocol) async -> FlowTaleAction? {
        switch action {
        case .prepareToPlayStudyWord(let word, let sentence):
            do {
                let chapter = try environment.loadChapter(storyId: word.storyId,
                                                          chapterIndex: sentence.chapterIndex) // TODO: Update this functionality to get expected chapter
                return .studyAction(.updateStudyChapter(chapter))
            } catch {
                return .studyAction(.failedToPrepareStudyWord)
            }
        case .playStudyWord(let word):
            let myTime = CMTime(seconds: word.time, preferredTimescale: 60000)
            await state.studyState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
            state.studyState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: word.time + word.duration, preferredTimescale: 60000)
            state.studyState.audioPlayer.playImmediately(atRate: state.settingsState.speechSpeed.playRate)

            return nil
        case .playStudySentence(let startWord, let endWord):
            let myTime = CMTime(seconds: startWord.time, preferredTimescale: 60000)
            await state.studyState.audioPlayer.seek(to: myTime, toleranceBefore: .zero, toleranceAfter: .zero)
            state.studyState.audioPlayer.currentItem?.forwardPlaybackEndTime = CMTime(seconds: endWord.time + endWord.duration, preferredTimescale: 60000)
            state.studyState.audioPlayer.playImmediately(atRate: state.settingsState.speechSpeed.playRate)
            let playLength = endWord.time + endWord.duration - startWord.time
            let speedModifiedPlayLength = playLength / Double(state.settingsState.speechSpeed.playRate)

            try? await Task.sleep(for: .seconds(speedModifiedPlayLength))

            if let duration = state.studyState.audioPlayer.currentItem?.duration.seconds,
               duration >= playLength {
                return .studyAction(.updateStudyAudioPlaying(false))
            }
            return nil

        case .pauseStudyAudio:
            state.studyState.audioPlayer.pause()
            return .studyAction(.updateStudyAudioPlaying(false))
        case .updateStudyChapter,
                .failedToPrepareStudyWord,
                .updateStudyAudioPlaying:
            return nil
        }
    }

}
