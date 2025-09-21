//
//  NavigationState.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import Settings

public struct NavigationState: Equatable {
    var contentTab: ContentTab
    var settings: SettingsState
    
    public init(
        contentTab: ContentTab = .reader,
        settings: SettingsState = SettingsState()
    ) {
        self.contentTab = contentTab
        self.settings = settings
    }
}
