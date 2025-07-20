//
//  SnackBarReducer.swift
//  SnackBar
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit

public struct SnackBarReducer: Reducer {
    public typealias State = SnackBarState
    public typealias Action = SnackBarAction
    
    public init() {}
    
    public func reduce(state: State, action: Action) -> State {
        var newState = state

        switch action {
        case .showSnackBar(let type),
              .showSnackBarThenSaveChapter(let type, _):
            newState.type = type
            newState.isShowing = true
            
        case .hideSnackbar:
            newState.isShowing = false
            
        case .hideSnackbarThenSaveChapterAndSettings:
            newState.isShowing = false

        case .checkDeviceVolumeZero:
            break
        }

        return newState
    }
}
