//
//  SnackBarMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 22/03/2025.
//

import ReduxKit

typealias SnackBarMiddlewareType = Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol>

let snackBarMiddleware: SnackBarMiddlewareType = { state, action, environment in
    switch action {
    case .snackBarAction(let snackBarAction):
        return await handleSnackBarAction(state: state, action: snackBarAction, environment: environment)
    default:
        return nil
    }

    func handleSnackBarAction(state: FlowTaleState,
                              action: SnackBarAction,
                              environment: FlowTaleEnvironmentProtocol) async -> FlowTaleAction? {
        switch action {
        case .showSnackBar(let type):
            state.appAudioState.audioPlayer.play()
            if let duration = type.showDuration {
                try? await Task.sleep(for: .seconds(duration))
                return .snackBarAction(.hideSnackbar)
            }
            return nil
        case .showSnackBarThenSaveStory(let type, let story):
            state.appAudioState.audioPlayer.play()

            if let duration = type.showDuration {
                try? await Task.sleep(for: .seconds(duration))
                return .hideSnackbarThenSaveStoryAndSettings(story)
            }
            return .storyAction(.saveStoryAndSettings(story))
        case .hideSnackbar:
            return nil
        }
    }

}
