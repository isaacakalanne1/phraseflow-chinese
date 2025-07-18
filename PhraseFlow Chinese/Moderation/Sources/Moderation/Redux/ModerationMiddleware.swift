//
//  ModerationMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 15/06/2025.
//

import Foundation
import ReduxKit

let moderationMiddleware: Middleware<ModerationState, ModerationAction, ModerationEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .moderateText(let prompt):
        do {
            let response = try await environment.moderateText(prompt)
            return .onModeratedText(response, prompt)
        } catch {
            return .failedToModerateText
        }
        
    case .onModeratedText(let response, let prompt):
        return response.didPassModeration ? .passedModeration(prompt) : .didNotPassModeration
        
    case .passedModeration:
        environment.saveAppSettings()
        return nil

    case .didNotPassModeration,
         .failedToModerateText:
        return nil
        
    case .dismissFailedModerationAlert,
         .showModerationDetails,
         .updateIsShowingModerationDetails:
        return nil
    }
}
