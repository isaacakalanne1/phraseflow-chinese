//
//  SettingsAction.swift
//  FlowTale
//
//  Created by iakalann on 22/03/2025.
//

enum SettingsAction {
    case loadAppSettings
    case onLoadedAppSettings(SettingsState)
    case failedToLoadAppSettings

    case saveAppSettings
    case failedToSaveAppSettings
}
