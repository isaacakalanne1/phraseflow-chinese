//
//  LoadingMiddleware.swift
//  Loading
//
//  Created by Isaac Akalanne on 19/07/2025.
//

import Foundation
import ReduxKit

@MainActor
let loadingMiddleware: Middleware<LoadingStatus, LoadingAction, LoadingEnvironmentProtocol> = { store, action, environment in
    switch action {
    case .updateLoadingStatus:
        return nil
    }
}
