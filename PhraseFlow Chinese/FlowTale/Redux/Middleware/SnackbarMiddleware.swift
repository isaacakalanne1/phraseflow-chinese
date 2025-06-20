//
//  SnackbarMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import AVKit
import Foundation
import ReduxKit

let snackbarMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .snackbarAction(let snackbarAction):
        switch snackbarAction {
        case .showSnackBar(let type):
            state.appAudioState.audioPlayer.play()
            if let duration = type.showDuration {
                try? await Task.sleep(for: .seconds(duration))
                return .snackbarAction(.hideSnackbar)
            }
            return nil
            
        case .showSnackBarThenSaveStory(let type, let story):
            state.appAudioState.audioPlayer.play()

            if let duration = type.showDuration {
                try? await Task.sleep(for: .seconds(duration))
                return .snackbarAction(.hideSnackbarThenSaveStoryAndSettings(story))
            } else {
                return .storyAction(.saveChapter(story.chapters.first!))
            }
            
        case .hideSnackbarThenSaveStoryAndSettings(_):
            if let currentChapter = state.storyState.currentChapter {
                return .storyAction(.saveChapter(currentChapter))
            } else if let firstStory = state.storyState.allStories.first,
                      let firstChapter = state.storyState.storyChapters[firstStory.storyId]?.first {
                return .storyAction(.saveChapter(firstChapter))
            }
            return nil
        case .checkDeviceVolumeZero:
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
            } catch {
                return nil
            }
            return audioSession.outputVolume == 0.0 ? .snackbarAction(.showSnackBar(.deviceVolumeZero)) : nil
        case .hideSnackbar:
            return nil
        }
    default:
        return nil
    }
}
