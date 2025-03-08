//
//  SnackBarType.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import SwiftUI

enum SnackBarType {
    case welcomeBack
    case writingChapter
    case chapterReady
    case storyReadyTapToRead
    case deletedCustomStory
    case subscribed
    case failedToWriteChapter
    case moderatingText
    case passedModeration
    case couldNotModerateText
    case didNotPassModeration
    case dailyChapterLimitReached(nextAvailable: String)
    case deviceVolumeZero

    var text: String {
        switch self {
        case .welcomeBack:
            LocalizedString.welcomeBack
        case .writingChapter:
            LocalizedString.writingChapter
        case .chapterReady:
            LocalizedString.chapterReady
        case .storyReadyTapToRead:
            LocalizedString.storyReadyTapToRead
        case .failedToWriteChapter:
            LocalizedString.snackbarFailedWriteChapter
        case .couldNotModerateText:
            LocalizedString.failedModerateText
        case .subscribed:
            LocalizedString.subscriptionComplete
        case .passedModeration:
            LocalizedString.customStoryAdded
        case .moderatingText:
            LocalizedString.moderatingStory
        case .didNotPassModeration:
            LocalizedString.storyDidNotMeetPolicies
        case .deletedCustomStory:
            LocalizedString.deletedCustomStory
        case .dailyChapterLimitReached(let nextAvailable):
            LocalizedString.snackbarDailyChapterLimitReached(nextAvailable)
        case .deviceVolumeZero:
            LocalizedString.deviceVolumeZero
        }
    }

    var showDuration: Double? {
        switch self {
        case .writingChapter:
            nil
        case .storyReadyTapToRead:
            10.0
        case .chapterReady,
                .failedToWriteChapter,
                .subscribed,
                .moderatingText,
                .passedModeration,
                .didNotPassModeration,
                .couldNotModerateText,
                .welcomeBack,
                .deletedCustomStory:
            2.5
        case .dailyChapterLimitReached:
            4
        case .deviceVolumeZero:
            5.0
        }
    }

    var iconView: some View {
        let emoji: String
        switch self {
        case .writingChapter:
            emoji = "✏️"
        case .moderatingText,
                .dailyChapterLimitReached:
            emoji = "⌛"
        case .chapterReady,
                .storyReadyTapToRead,
                .subscribed,
                .passedModeration,
                .deletedCustomStory:
            emoji = "✅"
        case .welcomeBack:
            emoji = "🔥"
        case .didNotPassModeration,
                .couldNotModerateText,
                .failedToWriteChapter:
            emoji = "⚠️"
        case .deviceVolumeZero:
            emoji = "🔇"
        }
        return Text(emoji)
    }

    func action(store: FlowTaleStore) {
        store.dispatch(.hideSnackbar)
        switch self {
        case .storyReadyTapToRead:
            // Load the newest story and set it as current when tapped
            if let newStory = store.state.storyState.savedStories.first {
                store.dispatch(.selectTab(.reader, shouldPlaySound: true))
                store.dispatch(.selectStoryFromSnackbar(newStory))
            }
        case .writingChapter:
            // Do nothing when tapping writing chapter
            break
        case .chapterReady:
            // When a chapter is ready, if there's no current story set, set the newest one
            if store.state.storyState.currentStory == nil, 
               let newStory = store.state.storyState.savedStories.first {
                store.dispatch(.selectStoryFromSnackbar(newStory))
            }
        case .subscribed,
                .moderatingText,
                .passedModeration,
                .didNotPassModeration,
                .welcomeBack,
                .deletedCustomStory,
                .failedToWriteChapter,
                .deviceVolumeZero:
            break
        case .couldNotModerateText:
            store.dispatch(.updateStorySetting(.customPrompt(store.state.settingsState.customPrompt)))
        case .dailyChapterLimitReached:
            store.dispatch(.showDailyLimitExplanationScreen(isShowing: true))
        }
    }

    var isError: Bool {
        switch self {
        case .writingChapter,
                .chapterReady,
                .subscribed,
                .moderatingText,
                .passedModeration,
                .welcomeBack,
                .deletedCustomStory,
                .dailyChapterLimitReached,
                .storyReadyTapToRead,
                .deviceVolumeZero:
            return false
        case .failedToWriteChapter,
                .didNotPassModeration,
                .couldNotModerateText:
            return true
        }
    }

    var backgroundColor: Color {
        isError ? FlowTaleColor.error : FlowTaleColor.accent
    }

    var sound: AppSound {
        switch self {
        case .writingChapter:
//            return .createStory
            return .largeBoom
        case _ where isError:
            return .errorSnackbar
        default:
            return .snackbar
        }
    }
}
