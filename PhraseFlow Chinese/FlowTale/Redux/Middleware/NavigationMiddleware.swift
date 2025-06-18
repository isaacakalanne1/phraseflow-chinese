//
//  NavigationMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit

let navigationMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .navigationAction(let navigationAction):
        switch navigationAction {
        case .selectChapter:
            return .navigationAction(.onSelectedChapter)
        case .onSelectedChapter:
            return .navigationAction(.selectTab(.reader, shouldPlaySound: false))
        case .selectTab(_, let shouldPlaySound):
            return shouldPlaySound ? .audioAction(.playSound(.tabPress)) : nil
        }
    default:
        return nil
    }
}