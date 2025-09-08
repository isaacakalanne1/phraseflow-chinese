//
//  DisplayedContentView.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import FTColor
import SwiftUI
import Story
import Study
import Settings
import Subscription
import Translation
import ReduxKit

struct DisplayedContentView: View {
    @EnvironmentObject var store: NavigationStore
    
    var body: some View {
        let translationStore: TranslationStore = Store(
            initial: TranslationState(),
            reducer: translationReducer,
            environment: store.environment.translationEnvironment,
            middleware: translationMiddleware
        )
        Group {
            switch store.state.contentTab {
            case .reader:
                NavigationStack {
                    StoryRootView(environment: store.environment.storyEnvironment)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(FTColor.background)
                }
            case .progress:
                StudyRootView(environment: store.environment.studyEnvironment)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .translate:
                TranslationRootView(store: translationStore)
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
