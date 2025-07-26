//
//  ModerationAction.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation

public enum ModerationAction: Sendable {
    case moderateText(String)
    case onModeratedText(ModerationResponse, String)
    case failedToModerateText
    
    case passedModeration(String)
    case didNotPassModeration
    
    case dismissFailedModerationAlert
    case showModerationDetails
    case updateIsShowingModerationDetails(isShowing: Bool)
}