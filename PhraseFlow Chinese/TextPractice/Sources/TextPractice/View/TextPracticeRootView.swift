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
    private let chapter: Chapter
    
    public init(
        environment: TextPracticeEnvironmentProtocol,
        chapter: Chapter,
        type: TextPracticeType,
        isViewingLastChapter: Bool = false
    ) {
        self.chapter = chapter
        self.store = Store(
            initial: TextPracticeState(
                isViewingLastChapter: isViewingLastChapter,
                chapter: chapter,
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
            .onAppear {
                store.dispatch(.prepareToPlayChapter(chapter))
            }
    }
}
