//
//  CreateStorySettingsView.swift
//  FlowTale
//
//  Created by iakalann on 25/07/2025.
//

import Audio
import SwiftUI
import ReduxKit
import Localization

public struct AppSettingsView: View {
    private var store: SettingsStore
    
    public init(
        settingsDataStore: SettingsDataStoreProtocol,
        audioEnvironment: AudioEnvironmentProtocol
    ) {
        let state = SettingsState()
        let environment = SettingsEnvironment(settingsDataStore: settingsDataStore,
                                              audioEnvironment: audioEnvironment)
        
        store = SettingsStore(
            initial: state,
            reducer: settingsReducer,
            environment: environment,
            middleware: settingsMiddleware,
            subscriber: settingsSubscriber
        )
    }
    
    public var body: some View {
        CreateStorySettingsView()
            .environmentObject(store)
            .navigationTitle(LocalizedString.settings)
    }
}
