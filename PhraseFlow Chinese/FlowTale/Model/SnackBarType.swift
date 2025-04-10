//
//  SnackBarType.swift
//  FlowTale
//
//  Created by iakalann on 27/12/2024.
//

import SwiftUI

enum SnackBarType: Equatable {
    case welcomeBack
    case writingChapter
    case chapterReady
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
        case let .dailyChapterLimitReached(nextAvailable):
            LocalizedString.snackbarDailyChapterLimitReached(nextAvailable)
        case .deviceVolumeZero:
            LocalizedString.deviceVolumeZero
        }
    }

    var showDuration: Double? {
        switch self {
        case .writingChapter:
            nil
        case .dailyChapterLimitReached:
            4
        case .deviceVolumeZero:
            5.0
        default:
            2.5
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
        case .couldNotModerateText:
            store.dispatch(.updateStorySetting(.customPrompt(store.state.settingsState.customPrompt)))
        case .dailyChapterLimitReached:
            store.dispatch(.showDailyLimitExplanationScreen(isShowing: true))
        default:
            break
        }
    }

    var isError: Bool {
        switch self {
        case .failedToWriteChapter,
             .didNotPassModeration,
             .couldNotModerateText:
            return true
        default:
            return false
        }
    }

    var backgroundColor: Color {
        isError ? FlowTaleColor.error : FlowTaleColor.accent
    }

    var sound: AppSound {
        switch self {
        case .writingChapter:
            return .largeBoom
        case _ where isError:
            return .errorSnackbar
        default:
            return .snackbar
        }
    }
}
