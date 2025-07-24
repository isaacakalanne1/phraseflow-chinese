//
//  ModerationView.swift
//  Moderation
//
//  Created by iakalann on 22/07/2025.
//

import SwiftUI
import ReduxKit

public struct ModerationView: View {
    private var store: ModerationStore
    private let customPrompt: String

    public init(moderationResponse: ModerationResponse? = nil,
                customPrompt: String = "") {
        let state = ModerationState(moderationResponse: moderationResponse)
        let environment = ModerationEnvironment()
        self.customPrompt = customPrompt

        store = ModerationStore(
            initial: state,
            reducer: moderationReducer,
            environment: environment,
            middleware: moderationMiddleware
        )
    }
    
    public var body: some View {
        ModerationExplanationView(customPrompt: customPrompt)
            .environmentObject(store)
    }
}
