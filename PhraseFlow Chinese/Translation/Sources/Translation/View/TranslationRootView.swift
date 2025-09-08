//
//  TranslationRootView.swift
//  Translation
//
//  Created by Claude on 26/07/2025.
//

import SwiftUI
import ReduxKit

public struct TranslationRootView: View {
    private let store: TranslationStore
    
    public init(store: TranslationStore) {
        self.store = store
    }
    
    public var body: some View {
        TranslationView()
            .environmentObject(store)
            .onAppear {
                store.dispatch(.loadAppSettings)
            }
    }
}
