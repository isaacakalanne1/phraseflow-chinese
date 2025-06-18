//
//  ModerationMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit

let moderationMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .moderationAction(let moderationAction):
        switch moderationAction {
        case .moderateText(let prompt):
            do {
                let response = try await environment.moderateText(prompt)
                return .moderationAction(.onModeratedText(response, prompt))
            } catch {
                return .moderationAction(.failedToModerateText)
            }
            
        case .onModeratedText(let response, let prompt):
            return response.didPassModeration ? .moderationAction(.passedModeration(prompt)) : .moderationAction(.didNotPassModeration)
            
        case .passedModeration:
            try? environment.saveAppSettings(state.settingsState)
            return .showSnackBar(.passedModeration)
            
        case .didNotPassModeration,
             .failedToModerateText:
            return .showSnackBar(.didNotPassModeration)
            
        case .dismissFailedModerationAlert,
             .showModerationDetails,
             .updateIsShowingModerationDetails:
            return nil
        }
    default:
        return nil
    }
}