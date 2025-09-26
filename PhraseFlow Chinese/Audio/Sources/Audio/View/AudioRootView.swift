//
//  AudioRootView.swift
//  Audio
//
//  Created by Isaac Akalanne on 23/09/2025.
//

import SwiftUI
import ReduxKit

public struct AudioRootView: View {
    @StateObject private var store: AudioStore
    
    public init(environment: AudioEnvironmentProtocol) {
        self._store = StateObject(wrappedValue: {
            Store(
                initial: AudioState(),
                reducer: audioReducer,
                environment: environment,
                middleware: audioMiddleware,
                subscriber: audioSubscriber
            )
        }())
    }

    public var body: some View {
        AudioView()
            .environmentObject(store)
    }
}
