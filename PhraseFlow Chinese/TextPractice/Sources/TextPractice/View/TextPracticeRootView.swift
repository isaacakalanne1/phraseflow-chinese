//
//  TextPracticeRootView.swift
//  TextPractice
//
//  Created by Isaac Akalanne on 02/09/2025.
//

import SwiftUI
import ReduxKit
import TextGeneration
import Settings
import Study

public struct TextPracticeRootView: View {
    private let store: TextPracticeStore
    
    public init(
        environment: TextPracticeEnvironmentProtocol,
        settings: SettingsState,
        type: TextPracticeType,
        isViewingLastChapter: Bool = false
    ) {
        self.store = Store(
            initial: TextPracticeState(
                isViewingLastChapter: isViewingLastChapter,
                settings: settings,
                textPracticeType: type
            ),
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
