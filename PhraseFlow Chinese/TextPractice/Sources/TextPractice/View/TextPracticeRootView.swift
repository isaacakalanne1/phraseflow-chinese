//
//  TextPracticeRootView.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import SwiftUI
import ReduxKit
import TextGeneration
import Study

public struct TextPracticeRootView: View {
    private let store: TextPracticeStore
    
    public init(
        environment: TextPracticeEnvironmentProtocol
    ) {
        self.store = Store(
            initial: TextPracticeState(),
            reducer: textPracticeReducer,
            environment: environment,
            middleware: textPracticeMiddleware,
            subscriber: textPracticeSubscriber
        )
    }
    
    public var body: some View {
        TextPracticeView()
            .environmentObject(store)
    }
}
