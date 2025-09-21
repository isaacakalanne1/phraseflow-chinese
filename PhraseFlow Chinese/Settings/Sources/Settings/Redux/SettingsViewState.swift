//
//  SettingsViewState.swift
//  Settings
//
//  Created by Isaac Akalanne on 21/09/2025.
//

import Foundation
import Moderation

public struct SettingsViewState: Codable, Equatable, Sendable {
    var isShowingModerationDetails: Bool
    var isWritingChapter: Bool
    var moderationResponse: ModerationResponse?
    
    public init(
        isShowingModerationDetails: Bool = false,
        isWritingChapter: Bool = false,
        moderationResponse: ModerationResponse? = nil
    ) {
        self.isShowingModerationDetails = isShowingModerationDetails
        self.isWritingChapter = isWritingChapter
        self.moderationResponse = moderationResponse
    }
    
    enum CodingKeys: String, CodingKey {
        case isShowingModerationDetails
        case isWritingChapter
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isShowingModerationDetails, forKey: .isShowingModerationDetails)
        try container.encode(isWritingChapter, forKey: .isWritingChapter)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isShowingModerationDetails = try container.decode(Bool.self, forKey: .isShowingModerationDetails)
        isWritingChapter = try container.decode(Bool.self, forKey: .isWritingChapter)
        moderationResponse = nil
    }
}
