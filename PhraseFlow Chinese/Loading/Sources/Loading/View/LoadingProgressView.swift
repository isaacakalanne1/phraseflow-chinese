//
//  LoadingProgressView.swift
//  Loading
//
//  Created by Isaac Akalanne on 19/07/2025.
//

import SwiftUI

public struct LoadingProgressView: View {
    private var store: LoadingStore
    
    public init(environment: LoadingEnvironmentProtocol) {
        let state = LoadingState()
        
        store = LoadingStore(
            initial: state,
            reducer: loadingReducer,
            environment: environment,
            middleware: loadingMiddleware,
            subscriber: loadingSubscriber
        )
    }
    
    public var body: some View {
        LoadingProgressBar()
            .environmentObject(store)
    }
}
