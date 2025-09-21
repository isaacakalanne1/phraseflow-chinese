//
//  NavigationState+Arrange.swift
//  Navigation
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Foundation
import Settings
import SettingsMocks
import Navigation

public extension NavigationState {
    static var arrange: NavigationState {
        .arrange()
    }
    
    static func arrange(
        contentTab: ContentTab = .reader,
        settings: SettingsState = .arrange
    ) -> NavigationState {
        .init(
            contentTab: contentTab,
            settings: settings
        )
    }
}
