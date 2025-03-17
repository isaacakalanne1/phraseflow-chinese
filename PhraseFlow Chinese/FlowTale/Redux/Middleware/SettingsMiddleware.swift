//
//  SettingsMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 22/03/2025.
//

import ReduxKit

typealias SettingsMiddlewareType = Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol>

let settingsMiddleware: SettingsMiddlewareType = { state, action, environment in
    switch action {
    case .settingsAction(let settingsAction):
        return handleSettingsAction(state: state, action: settingsAction, environment: environment)
    default:
        return nil
    }

    func handleSettingsAction(state: FlowTaleState,
                              action: SettingsAction,
                              environment: FlowTaleEnvironmentProtocol) -> FlowTaleAction? {
        switch action {
        case .saveAppSettings:
            do {
                try environment.saveAppSettings(state.settingsState)
                return nil
            } catch {
                return .settingsAction(.failedToSaveAppSettings)
            }
        case .loadAppSettings:
            do {
                let settings = try environment.loadAppSettings()
                return .settingsAction(.onLoadedAppSettings(settings))
            } catch {
                return .settingsAction(.failedToLoadAppSettings)
            }
        case .onLoadedAppSettings:
            if state.settingsState.isPlayingMusic {
                return .playMusic(.whispersOfTheForest)
            }
            return nil
        case .failedToLoadAppSettings,
                .failedToSaveAppSettings:
            return nil
        }
    }

}
