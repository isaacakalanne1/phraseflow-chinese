//
//  ModerationRootView.swift
//  Moderation
//
//  Created by Claude on 26/07/2025.
//

import SwiftUI
import ReduxKit

public struct ModerationRootView: View {
    private let customPrompt: String
    private let moderationResponse: ModerationResponse?
    
    public init(
        moderationResponse: ModerationResponse?,
        customPrompt: String = ""
    ) {
        self.customPrompt = customPrompt
        self.moderationResponse = moderationResponse
    }
    
    public var body: some View {
        ModerationExplanationView(
            customPrompt: customPrompt,
            moderationResponse: moderationResponse
        )
    }
}
