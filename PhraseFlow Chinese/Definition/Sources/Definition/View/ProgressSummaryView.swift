//
//  ProgressSummaryView.swift
//  Definition
//
//  Created by Isaac Akalanne on 19/07/2025.
//

import SwiftUI

public struct ProgressSummaryView: View {
    private var store: DefinitionStore

    public init() {
        let state = DefinitionState()
        let environment = DefinitionEnvironment()

        store = DefinitionStore(
            initial: state,
            reducer: definitionReducer,
            environment: environment,
            middleware: definitionMiddleware,
            subscriber: definitionSubscriber
        )
    }
    
    public var body: some View {
        DefinitionsProgressSheetView()
            .environmentObject(store)
    }
}
