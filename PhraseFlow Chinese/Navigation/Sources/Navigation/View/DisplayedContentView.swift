//
//  DisplayedContentView.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import SwiftUI
import Story
import Settings

struct DisplayedContentView: View {
    @EnvironmentObject var store: NavigationStore
    
    var body: some View {
        Group {
            switch store.state.contentTab {
            case .reader:
                StoryRootView(environment: store.environment.storyEnvironment)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .progress:
                Text("Progress View")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .translate:
                Text("Translate View")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .subscribe:
                Text("Subscribe View")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .settings:
                SettingsRootView(environment: store.environment.settingsEnvironment)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

#Preview {
    DisplayedContentView()
}
