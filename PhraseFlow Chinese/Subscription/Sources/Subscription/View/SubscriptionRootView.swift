//
//  SubscriptionRootView.swift
//  FlowTale
//
//  Created by Claude on 26/07/2025.
//

import SwiftUI
import ReduxKit

public struct SubscriptionRootView: View {
    private let store: SubscriptionStore
    
    public init(environment: SubscriptionEnvironmentProtocol) {
        self.store = Store(
            initial: SubscriptionState(),
            reducer: subscriptionReducer,
            environment: environment,
            middleware: subscriptionMiddleware
        )
        store.dispatch(.fetchSubscriptions)
    }
    
    public var body: some View {
        SubscriptionView()
            .environmentObject(store)
    }
}
