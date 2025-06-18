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

    case .showSnackBar(let type):
        state.appAudioState.audioPlayer.play()
        if let duration = type.showDuration {
            try? await Task.sleep(for: .seconds(duration))
            return .hideSnackbar
        }
        return nil
        
    case .showSnackBarThenSaveStory(let type, let story):
        state.appAudioState.audioPlayer.play()

        if let duration = type.showDuration {
            try? await Task.sleep(for: .seconds(duration))
            return .hideSnackbarThenSaveStoryAndSettings(story)
        } else {
            return .storyAction(.saveStoryAndSettings(story))
        }
        
    case .hideSnackbarThenSaveStoryAndSettings(_):
        if let currentStory = state.storyState.currentStory {
            return .storyAction(.saveStoryAndSettings(currentStory))
        } else if let firstStory = state.storyState.savedStories.first {
            return .storyAction(.saveStoryAndSettings(firstStory))
        }
        return nil
    case .selectChapter:
        return .onSelectedChapter
    case .onSelectedChapter:
        return .selectTab(.reader, shouldPlaySound: false)
    case .checkDeviceVolumeZero:
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(true)
        } catch {
            return nil
        }
        return audioSession.outputVolume == 0.0 ? .showSnackBar(.deviceVolumeZero) : nil
    case .selectTab(_, let shouldPlaySound):
        return shouldPlaySound ? .audioAction(.playSound(.tabPress)) : nil
    case .failedToSaveStory,
            .refreshChapterView,
            .refreshTranslationView,
            .failedToSaveStoryAndSettings,
            .refreshStoryListView,
            .updateAutoScrollEnabled,
            .hideSnackbar,
            .updateCurrentSentence,
            .clearCurrentDefinition,
            .updateLoadingState:
        return nil
    }
}
