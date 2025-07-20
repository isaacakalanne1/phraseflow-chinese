//
//  TranslatorView.swift
//  Translation
//
//  Created by Isaac Akalanne on 20/07/2025.
//

import SwiftUI

public struct TranslatorView: View {
    private var store: TranslationStore

    public init() {
        let state = TranslationState()
        let environment = TranslationEnvironment()

        store = TranslationStore(
            initial: state,
            reducer: translationReducer,
            environment: environment,
            middleware: translationMiddleware,
            subscriber: translationSubscriber
        )
    }
    
    public var body: some View {
        TranslationView()
            .environmentObject(store)
    }
}
