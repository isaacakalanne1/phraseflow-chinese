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
    case .selectTab(_, let shouldPlaySound):
        if shouldPlaySound {
            environment.playSound(.tabPress)
        }
        return nil
    case .showFreeLimitExplanation,
            .showDailyLimitExplanation,
            .dismissLimitExplanation:
        return nil
    }
}
