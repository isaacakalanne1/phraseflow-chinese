//
//  ModerationState.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation

struct ModerationState {
    var moderationResponse: ModerationResponse?
    var isShowingModerationFailedAlert = false
    var isShowingModerationDetails = false
    
    init(moderationResponse: ModerationResponse? = nil,
         isShowingModerationFailedAlert: Bool = false,
         isShowingModerationDetails: Bool = false) {
        self.moderationResponse = moderationResponse
        self.isShowingModerationFailedAlert = isShowingModerationFailedAlert
        self.isShowingModerationDetails = isShowingModerationDetails
    }
}
