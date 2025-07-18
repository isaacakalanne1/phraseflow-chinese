//
//  NavigationReducer.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import SwiftUI
import ReduxKit
import AVKit

@MainActor
let navigationReducer: Reducer<NavigationState, NavigationAction> = { state, action in
    var newState = state

    switch action {
    case .selectChapter:
        newState.contentTab = .reader
        
    case .selectTab(let tab, _):
        newState.contentTab = tab
    }

    return newState
}
