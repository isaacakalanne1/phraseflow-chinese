//
//  NavigationAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Settings

enum NavigationAction: Equatable, Sendable {
    case selectTab(ContentTab)
    case refreshAppSettings(SettingsState)
}
