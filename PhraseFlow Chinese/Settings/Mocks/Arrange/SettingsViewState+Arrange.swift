//
//  SettingsState+Arrange.swift
//  Settings
//
//  Created by Isaac Akalanne on 18/09/2025.
//

import Settings
import Moderation
import ModerationMocks

extension SettingsViewState {
    static var arrange: SettingsViewState {
        .arrange()
    }
    
    static func arrange(
        isShowingModerationDetails: Bool = false,
        isWritingChapter: Bool = false,
        moderationResponse: ModerationResponse? = .arrange
    ) -> SettingsViewState {
        .init(
            isShowingModerationDetails: isShowingModerationDetails,
            isWritingChapter: isWritingChapter,
            moderationResponse: moderationResponse
        )
    }
}
