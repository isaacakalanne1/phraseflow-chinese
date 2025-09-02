//
//  TextPracticeRootView.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import SwiftUI
import ReduxKit

public struct TextPracticeRootView: View {
    private let store: TextPracticeStore
    
    public init(environment: TextPracticeEnvironmentProtocol) {
        self.store = Store(
            initial: TextPracticeState(),
            reducer: textPracticeReducer,
            environment: environment,
            middleware: textPracticeMiddleware
        )
    }
    
    public var body: some View {
        TextPracticeView()
            .environmentObject(store)
            .onAppear {
                store.dispatch(.loadStoriesAndDefinitions)
            }
    }
}
