//
//  NavigationMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit

@MainActor
let navigationMiddleware: Middleware<NavigationState, NavigationAction, NavigationEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .selectChapter(let storyId, _):
        environment.selectChapter(storyId: storyId)
        return nil
    case .selectTab(_, let shouldPlaySound):
        return shouldPlaySound ? .audioAction(.playSound(.tabPress)) : nil
    }
}
