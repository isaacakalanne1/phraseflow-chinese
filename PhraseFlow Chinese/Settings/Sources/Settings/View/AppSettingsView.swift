import SwiftUI
import ReduxKit
import Localization

public struct AppSettingsView: View {
    private var store: SettingsStore
    
    public init() {
        let state = SettingsState()
        let environment = SettingsEnvironment()
        
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
