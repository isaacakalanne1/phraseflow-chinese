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
    private var store: DefinitionStore

    public init(definitionServices: DefinitionServicesProtocol,
                dataStore: DefinitionDataStoreProtocol,
                audioEnvironment: AudioEnvironmentProtocol,
                settingsEnvironment: SettingsEnvironmentProtocol) {
        let state = DefinitionState()
        let environment = DefinitionEnvironment(definitionServices: definitionServices,
                                                dataStore: dataStore,
                                                audioEnvironment: audioEnvironment,
                                                settingsEnvironment: settingsEnvironment)

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
            .onAppear {
                store.dispatch(.onAppear)
            }
    }
}
