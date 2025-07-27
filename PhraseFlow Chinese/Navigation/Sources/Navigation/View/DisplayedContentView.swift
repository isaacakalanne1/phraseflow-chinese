//
//  DisplayedContentView.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import SwiftUI
import Story
import Study
import Settings
import Subscription
import Translation

struct DisplayedContentView: View {
    @EnvironmentObject var store: NavigationStore
    
    var body: some View {
        Group {
            switch store.state.contentTab {
            case .reader:
                StoryRootView(environment: store.environment.storyEnvironment)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .progress:
                ProgressSummaryView(environment: store.environment.studyEnvironment)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .translate:
                TranslationRootView(environment: store.environment.translationEnvironment)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .subscribe:
                SubscriptionRootView(environment: store.environment.subscriptionEnvironment)
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
