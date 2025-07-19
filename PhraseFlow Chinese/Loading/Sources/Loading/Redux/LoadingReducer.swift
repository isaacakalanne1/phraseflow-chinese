//
//  LoadingReducer.swift
//  Loading
//
//  Created by Isaac Akalanne on 19/07/2025.
//

import Foundation
import ReduxKit

@MainActor
let loadingReducer: Reducer<LoadingState, LoadingAction> = { state, action in
    var newState = state
    switch action {
    case .updateLoadingStatus(let newStatus):
        newState.loadingStatus = newStatus
    }
    return newState
}
