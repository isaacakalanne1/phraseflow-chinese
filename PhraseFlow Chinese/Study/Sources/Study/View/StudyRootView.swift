//
//  StudyRootView.swift
//  Definition
//
//  Created by Isaac Akalanne on 19/07/2025.
//

import Audio
import Settings
import SwiftUI

public struct StudyRootView: View {
    @StateObject private var store: StudyStore

    public init(environment: StudyEnvironmentProtocol) {
        self._store = StateObject(wrappedValue: {
            StudyStore(
                initial: StudyState(),
                reducer: studyReducer,
                environment: environment,
                middleware: studyMiddleware,
                subscriber: studySubscriber
            )
        }())
    }
    
    public var body: some View {
        NavigationStack {
            DefinitionsProgressView()
                .environmentObject(store)
                .onAppear {
                    store.dispatch(.loadDefinitions)
                }
        }
    }
}
