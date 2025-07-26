//
//  ModerationState.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation

public struct ModerationState: Equatable {
    var moderationResponse: ModerationResponse?
    var moderationRecord: ModerationRecord?
    var isShowingModerationFailedAlert = false
    var isShowingModerationDetails = false
    
    public init(moderationResponse: ModerationResponse? = nil,
         moderationRecord: ModerationRecord? = nil,
         isShowingModerationFailedAlert: Bool = false,
         isShowingModerationDetails: Bool = false) {
        self.moderationResponse = moderationResponse
        self.moderationRecord = moderationRecord
        self.isShowingModerationFailedAlert = isShowingModerationFailedAlert
        self.isShowingModerationDetails = isShowingModerationDetails
    }
}
