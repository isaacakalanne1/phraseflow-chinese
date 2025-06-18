//
//  FlowTaleReducer.swift
//  FlowTale
//
//  Created by iakalann on 10/09/2024.
//

import SwiftUI
import ReduxKit
import AVKit
import StoreKit

let flowTaleReducer: Reducer<FlowTaleState, FlowTaleAction> = { state, action in
    var newState = state

    switch action {
    case .studyAction(let studyAction):
        newState.studyState = studyReducer(state.studyState, studyAction)
        
    case .translationAction(let translationAction):
        newState.translationState = translationReducer(state.translationState, translationAction)
        
    case .storyAction(let storyAction):
        newState = storyReducer(state, storyAction)
        
    case .audioAction(let audioAction):
        newState = audioReducer(state, audioAction)

    case .subscriptionAction(let subscriptionAction):
        newState = subscriptionReducer(state, subscriptionAction)

    case .definitionAction(let definitionAction):
        newState = definitionReducer(state, definitionAction)
        
    case .appSettingsAction(let appSettingsAction):
        newState = appSettingsReducer(state, appSettingsAction)
        
    case .moderationAction(let moderationAction):
        newState = moderationReducer(state, moderationAction)
        
    case .userLimitAction(let userLimitAction):
        newState = userLimitReducer(state, userLimitAction)
    case .updateCurrentSentence(let sentence):
        newState.storyState.currentSentence = sentence
    case .clearCurrentDefinition:
        newState.definitionState.currentDefinition = nil
    case .updateAutoScrollEnabled(let isEnabled):
        newState.viewState.isAutoscrollEnabled = isEnabled
    case .selectChapter(var story, let chapterIndex):
        if let chapter = story.chapters[safe: chapterIndex] {
            newState.definitionState.currentDefinition = nil
            story.lastUpdated = .now
            newState.storyState.currentStory = story
            newState.settingsState.language = story.language

            if let voice = chapter.audioVoice {
                newState.settingsState.voice = voice
            }

            story.currentChapterIndex = chapterIndex
            let data = newState.storyState.currentChapter?.audio.data
            newState.audioState.audioPlayer = data?.createAVPlayer() ?? AVPlayer()
        }
    case .onSelectedChapter:
        if let language = newState.storyState.currentStory?.language {
            newState.settingsState.language = language
        }
    case .refreshChapterView:
        newState.viewState.chapterViewId = UUID()
    case .refreshTranslationView:
        newState.viewState.translationViewId = UUID()
    case .refreshStoryListView:
        newState.viewState.storyListViewId = UUID()
    case .showSnackBar(let type),
          .showSnackBarThenSaveStory(let type, _):
        if let url = type.sound.fileURL,
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.volume = 0.7
            newState.appAudioState.audioPlayer = player
        }
        newState.snackBarState.type = type
        newState.snackBarState.isShowing = true
    case .hideSnackbar:
        newState.snackBarState.isShowing = false
    case .selectTab(let tab, _):
        newState.viewState.contentTab = tab
    case .hideSnackbarThenSaveStoryAndSettings:
        newState.snackBarState.isShowing = false
    case .updateLoadingState(let loadingState):
        newState.viewState.loadingState = loadingState
    case .failedToSaveStory,
            .failedToSaveStoryAndSettings,
            .checkDeviceVolumeZero:
        break
    }

    return newState
}
