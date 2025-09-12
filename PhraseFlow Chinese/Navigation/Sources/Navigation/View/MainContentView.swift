//
//  MainContentView.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import FTColor
import Loading
import SwiftUI
import UserLimit

public struct MainContentView: View {
    private var store: NavigationStore
    private let environment: NavigationEnvironmentProtocol

    public init(environment: NavigationEnvironmentProtocol) {
        let state = NavigationState()
        self.environment = environment

        store = NavigationStore(
            initial: state,
            reducer: navigationReducer,
            environment: environment,
            middleware: navigationMiddleware,
            subscriber: navigationSubscriber
        )
    }
    
    public var body: some View {
        VStack {
            LoadingProgressView(environment: environment.loadingEnvironment)
            DisplayedContentView()
            Divider()
                .background(FTColor.secondary)
                .padding(.horizontal)
            TabBarView()
        }
        .background(FTColor.background)
        .environmentObject(store)
        .sheet(isPresented: Binding<Bool>(
            get: { store.state.isShowingFreeLimitExplanation },
            set: { _ in store.dispatch(.dismissLimitExplanation) }
        )) {
            FreeLimitExplanationView {
                store.dispatch(.dismissLimitExplanation)
            }
        }
        .sheet(isPresented: Binding<Bool>(
            get: { store.state.isShowingDailyLimitExplanation },
            set: { _ in store.dispatch(.dismissLimitExplanation) }
        )) {
            DailyLimitExplanationView(nextAvailable: store.state.dailyLimitNextAvailable) {
                store.dispatch(.dismissLimitExplanation)
            }
        }
    }
}

// #Preview {
//     MainContentView(environment: NavigationEnvironment(
//         storyEnvironment: MockStoryEnvironment(),
//         audioEnvironment: MockAudioEnvironment()
//     ))
// }
