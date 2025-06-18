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
    case .checkFreeTrialLimit:
        return nil

    case .onDailyChapterLimitReached(let nextAvailable):
        return .showSnackBar(.dailyChapterLimitReached(nextAvailable: nextAvailable))

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
        try? environment.saveAppSettings(state.settingsState)
        return .showSnackBar(.passedModeration)
    case .didNotPassModeration,
            .failedToModerateText:
        return .showSnackBar(.didNotPassModeration)
    case .selectTab(_, let shouldPlaySound):
        return shouldPlaySound ? .audioAction(.playSound(.tabPress)) : nil
    case .failedToSaveStory,
            .refreshChapterView,
            .refreshTranslationView,
            .failedToSaveStoryAndSettings,
            .refreshStoryListView,
            .updateAutoScrollEnabled,
            .hideSnackbar,
            .dismissFailedModerationAlert,
            .showModerationDetails,
            .updateIsShowingModerationDetails,
            .showDailyLimitExplanationScreen,
            .hasReachedFreeTrialLimit,
            .hasReachedDailyLimit,
            .showFreeLimitExplanationScreen,
            .selectStoryFromSnackbar,
            .updateCurrentSentence,
            .clearCurrentDefinition,
            .updateLoadingState:
        return nil
    }
}
