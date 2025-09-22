//
//  SnackbarView.swift
//  SnackBar
//
//  Created by Isaac Akalanne on 25/07/2025.
//

import SwiftUI
import ReduxKit

public struct SnackbarView: View {
    @StateObject private var store: SnackBarStore
    
    public init(
        environment: SnackBarEnvironmentProtocol
    ) {
        let state = SnackBarState()
        
        self._store = StateObject(wrappedValue: {
            SnackBarStore(
                initial: state,
                reducer: snackBarReducer,
                environment: environment,
                middleware: snackBarMiddleware,
                subscriber: snackBarSubscriber
            )
        }())
    }
    
    public var body: some View {
        SnackBarContentView()
            .environmentObject(store)
    }
}
