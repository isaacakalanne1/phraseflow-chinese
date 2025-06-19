//
//  FlowTaleMiddleware.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import Foundation
import ReduxKit
import AVKit
import StoreKit
import AVFoundation

let flowTaleMiddleware: Middleware<FlowTaleState, FlowTaleAction, FlowTaleEnvironmentProtocol> = { state, action, environment in
    switch action {
    case .translationAction(let translationAction):
        return await translationMiddleware(state, action, environment)
    case .studyAction(let studyAction):
        return await studyMiddleware(state, .studyAction(studyAction), environment)
    case .storyAction(let storyAction):
        return await storyMiddleware(state, .storyAction(storyAction), environment)
    case .audioAction(let audioAction):
        return await audioMiddleware(state, .audioAction(audioAction), environment)
    case .definitionAction(let definitionAction):
        return await definitionMiddleware(state, .definitionAction(definitionAction), environment)
    case .subscriptionAction(let subscriptionAction):
        return await subscriptionMiddleware(state, .subscriptionAction(subscriptionAction), environment)
    case .appSettingsAction(let appSettingsAction):
        return await appSettingsMiddleware(state, .appSettingsAction(appSettingsAction), environment)
    case .moderationAction(let moderationAction):
        return await moderationMiddleware(state, .moderationAction(moderationAction), environment)
    case .userLimitAction(let userLimitAction):
        return await userLimitMiddleware(state, .userLimitAction(userLimitAction), environment)
    case .navigationAction(let navigationAction):
        return await navigationMiddleware(state, .navigationAction(navigationAction), environment)
    case .snackbarAction(let snackbarAction):
        return await snackbarMiddleware(state, .snackbarAction(snackbarAction), environment)

    case .checkDeviceVolumeZero:
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            return nil
        }
        return audioSession.outputVolume == 0.0 ? .snackbarAction(.showSnackBar(.deviceVolumeZero)) : nil
    case .updateAutoScrollEnabled,
            .updateCurrentSentence,
            .updateLoadingState:
        return nil
    }
}
