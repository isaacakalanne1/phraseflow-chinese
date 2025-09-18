//
//  NavigationState.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import Settings

struct NavigationState: Equatable {
    var contentTab: ContentTab = .reader
    var settings = SettingsState()
}
