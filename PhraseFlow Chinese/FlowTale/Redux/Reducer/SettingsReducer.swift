//
//  SettingsReducer.swift
//  FlowTale
//
//  Created by iakalann on 22/03/2025.
//

import ReduxKit

let settingsReducer: Reducer<SettingsState, SettingsAction> = { state, action in

    var newState = state
    switch action {
    case .onLoadedAppSettings(let settings):
        newState = settings
    case .saveAppSettings,
            .failedToSaveAppSettings,
            .loadAppSettings,
            .failedToLoadAppSettings:
        break
    }

    return newState
}
