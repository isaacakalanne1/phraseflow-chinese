//
//  LoadingMiddleware.swift
//  Loading
//
//  Created by Isaac Akalanne on 19/07/2025.
//

import Foundation
import ReduxKit

@MainActor
let loadingMiddleware: Middleware<LoadingState, LoadingAction, LoadingEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .updateLoadingStatus(let status):
        switch status {
        case .complete:
            try? await Task.sleep(for: .seconds(2))
            return .updateLoadingStatus(.none)
        default:
            return nil
        }
    }
}
