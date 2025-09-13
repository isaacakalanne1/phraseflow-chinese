//
//  ModerationRootView.swift
//  Moderation
//
//  Created by Claude on 26/07/2025.
//

import SwiftUI
import ReduxKit

public struct ModerationRootView: View {
    @StateObject private var store: ModerationStore
    private let customPrompt: String
    
    public init(environment: ModerationEnvironmentProtocol, 
                moderationResponse: ModerationResponse? = nil,
                customPrompt: String = "") {
        self.customPrompt = customPrompt
        
        self._store = StateObject(wrappedValue: {
            Store(
                initial: ModerationState(moderationResponse: moderationResponse),
                reducer: moderationReducer,
                environment: environment,
                middleware: moderationMiddleware
            )
        }())
    }
    
    public var body: some View {
        ModerationExplanationView(customPrompt: customPrompt)
            .environmentObject(store)
    }
}
