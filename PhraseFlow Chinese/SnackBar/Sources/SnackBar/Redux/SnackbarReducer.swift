//
//  SnackBarReducer.swift
//  SnackBar
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit

@MainActor
public let snackBarReducer: Reducer<SnackBarState, SnackBarAction> = { state, action in
    var newState = state

    switch action {
    case .setType(let type):
        newState.type = type
        
    case .showSnackbar:
        newState.isShowing = true
        
    case .hideSnackbar:
        newState.isShowing = false

    case .checkDeviceVolumeZero:
        break
    }

    return newState
}
