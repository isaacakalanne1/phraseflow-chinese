//
//  TranslationRootView.swift
//  Translation
//
//  Created by Claude on 26/07/2025.
//

import SwiftUI
import ReduxKit

public struct TranslationRootView: View {
    private let store: TranslationStore
    
    public init(environment: TranslationEnvironmentProtocol) {
        self.store = Store(
            initial: TranslationState(),
            reducer: translationReducer,
            environment: environment,
            middleware: translationMiddleware
        )
    }
    
    public var body: some View {
        TranslationView()
            .environmentObject(store)
    }
}