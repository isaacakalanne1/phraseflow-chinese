//
//  MainContentView.swift
//  Navigation
//
//  Created by iakalann on 17/07/2025.
//

import FTColor
import Loading
import SwiftUI
import SnackBar

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
        ZStack {
            VStack {
                LoadingProgressView(environment: environment.loadingEnvironment)
                DisplayedContentView()
                Divider()
                    .background(FTColor.secondary.color)
                    .padding(.horizontal)
                TabBarView()
            }
            SnackbarView(environment: environment.snackbarEnvironment)
        }
        .background(FTColor.background.color)
        .environmentObject(store)
    }
}
