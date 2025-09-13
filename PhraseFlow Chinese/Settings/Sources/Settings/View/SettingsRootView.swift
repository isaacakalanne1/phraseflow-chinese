//
//  SettingsRootView.swift
//  Settings
//
//  Created by Claude on 26/07/2025.
//

import SwiftUI
import ReduxKit

public struct SettingsRootView: View {
    @StateObject private var store: SettingsStore
    
    public init(environment: SettingsEnvironmentProtocol) {
        self._store = StateObject(wrappedValue: {
            Store(
                initial: SettingsState(),
                reducer: settingsReducer,
                environment: environment,
                middleware: settingsMiddleware,
                subscriber: settingsSubscriber
            )
        }())
    }
    
    public var body: some View {
        SettingsView()
            .environmentObject(store)
            .onAppear {
                store.dispatch(.loadAppSettings)
            }
    }
}
