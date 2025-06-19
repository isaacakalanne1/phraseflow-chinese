//
//  SnackbarMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

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
                return .storyAction(.saveStoryAndSettings(story))
            }
            
        case .hideSnackbarThenSaveStoryAndSettings(_):
            if let currentStory = state.storyState.currentStory {
                return .storyAction(.saveStoryAndSettings(currentStory))
            } else if let firstStory = state.storyState.savedStories.first {
                return .storyAction(.saveStoryAndSettings(firstStory))
            }
            return nil
            
        case .hideSnackbar:
            return nil
        }
    default:
        return nil
    }
}