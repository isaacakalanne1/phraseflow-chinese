//
//  SnackbarView.swift
//  SnackBar
//
//  Created by Claude on 25/07/2025.
//

import SwiftUI
import ReduxKit

public struct SnackbarView: View {
    private var store: SnackBarStore
    
    public init() {
        let state = SnackBarState()
        let environment = SnackBarEnvironment()
        
        store = SnackBarStore(
            initial: state,
            reducer: snackBarReducer,
            environment: environment,
            middleware: snackBarMiddleware,
            subscriber: snackBarSubscriber
        )
    }
    
    public var body: some View {
        SnackBarContentView()
            .environmentObject(store)
    }
}
