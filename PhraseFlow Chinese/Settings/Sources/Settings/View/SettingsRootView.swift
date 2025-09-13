//
//  SettingsRootView.swift
//  Settings
//
//  Created by Claude on 26/07/2025.
//

import SwiftUI
import ReduxKit

public struct SettingsRootView: View {
    private let store: SettingsStore
    
    public init(environment: SettingsEnvironmentProtocol) {
        self.store = Store(
            initial: SettingsState(),
            reducer: settingsReducer,
            environment: environment,
            middleware: settingsMiddleware,
            subscriber: settingsSubscriber
        )
    }
    
    public var body: some View {
        SettingsView()
            .environmentObject(store)
            .onAppear {
                store.dispatch(.loadAppSettings)
            }
    }
}
