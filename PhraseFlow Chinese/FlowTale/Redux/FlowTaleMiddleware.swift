//
//  FlowTaleMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 18/07/2025.
//

import Foundation
import ReduxKit
import Moderation
import SnackBar
import Settings

let flowTaleMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .moderationAction(let moderationAction):
        switch moderationAction {
        case .passedModeration(let prompt):
            // Update settings state with the passed prompt
            var newSettingsState = state.settingsState
            newSettingsState.customPrompts.append(prompt)
            newSettingsState.storySetting = .customPrompt(prompt)
            
            // Return snackbar action to show success
            return .snackbarAction(.showSnackBar(.passedModeration))
            
        case .didNotPassModeration:
            // Return snackbar action to show failure
            return .snackbarAction(.showSnackBar(.didNotPassModeration))
            
        default:
            return nil
        }
    default:
        return nil
    }
}