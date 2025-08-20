//
//  ProgressSummaryView.swift
//  Definition
//
//  Created by Isaac Akalanne on 19/07/2025.
//

import Audio
import Settings
import SwiftUI

public struct ProgressSummaryView: View {
    private var store: StudyStore

    public init(environment: StudyEnvironmentProtocol) {
        store = StudyStore(
            initial: StudyState(),
            reducer: studyReducer,
            environment: environment,
            middleware: studyMiddleware,
            subscriber: studySubscriber
        )
    }
    
    public var body: some View {
        DefinitionsProgressView()
            .environmentObject(store)
            .onAppear {
                store.dispatch(.loadDefinitions)
            }
    }
}
