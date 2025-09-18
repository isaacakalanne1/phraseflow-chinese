//
//  TranslationRootView.swift
//  Translation
//
//  Created by Isaac Akalanne on 26/07/2025.
//

import SwiftUI
import ReduxKit

public struct TranslationRootView: View {
    @StateObject private var store: TranslationStore
    
    public init(environment: TranslationEnvironmentProtocol) {
        self._store = StateObject(wrappedValue: {
            Store(
                initial: TranslationState(),
                reducer: translationReducer,
                environment: environment,
                middleware: translationMiddleware,
                subscriber: translationSubscriber
            )
        }())
    }
    
    public var body: some View {
        TranslationView()
            .environmentObject(store)
            .onAppear {
                store.dispatch(.loadTranslationHistory)
            }
    }
}
